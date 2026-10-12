// ============================================================
// detail_page.dart — Floor-by-Floor Inspector, AI Summary & Reviews
// ============================================================

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models.dart';
import '../store.dart';
import 'auth_page.dart';

class DetailPage extends StatefulWidget {
  final Place place;
  const DetailPage(this.place, {super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int _selectedFloorIndex = 0;
  String _aiTone = 'Standard';
  bool _isAiGenerating = false;
  String _reviewFilter = 'all'; // 'all', 'disabled', 'general'

  Widget _photo(String path, {double h = 160}) {
    Widget imgWidget;
    if (path.startsWith('assets/')) {
      imgWidget = Image.asset(
        path,
        height: h,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _photoPlaceholder(h),
      );
    } else if (path.startsWith('http://') || path.startsWith('https://')) {
      imgWidget = Image.network(
        path,
        height: h,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _photoPlaceholder(h),
      );
    } else if (kIsWeb) {
      imgWidget = Image.network(
        path,
        height: h,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _photoPlaceholder(h),
      );
    } else {
      imgWidget = Image.file(
        File(path),
        height: h,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _photoPlaceholder(h),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: imgWidget,
    );
  }

  Widget _photoPlaceholder(double h) {
    return Container(
      height: h,
      width: double.infinity,
      color: const Color(0xFFF1F5F9),
      child: const Center(
        child: Icon(Icons.image_outlined, color: Color(0xFF94A3B8), size: 36),
      ),
    );
  }

  void _regenerateAiSummary() {
    setState(() => _isAiGenerating = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _isAiGenerating = false);
      }
    });
  }

  void _openFeedbackSheet(Place p) {
    if (store.currentUser == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.lock_person_rounded, color: Color(0xFF0F766E)),
              SizedBox(width: 8),
              Text('Account Required'),
            ],
          ),
          content: const Text(
            'Community feedback quality maintain rakhne ke liye pehle apna student ya admin account login karein.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0F766E)),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthPage()),
                );
              },
              child: const Text('Sign In / Register 👤'),
            ),
          ],
        ),
      );
      return;
    }

    // 5 facility scores (nullable if unchecked)
    final facilityActive = [true, true, true, true, true];
    final scores = [5, 5, 4, 4, 4];
    final commentCtrl = TextEditingController();
    String? photoPath;
    String selectedFeature = 'General Building Experience';
    int? selectedTargetFloor;

    // Dual-tier reviewer type
    final isUserDisabledByDefault = store.currentUser?.needsPreference != 'None' && store.currentUser?.needsPreference != 'General';
    String userCategory = isUserDisabledByDefault ? 'disabled' : 'general';
    String disabilityType = 'Wheelchair / Mobility';

    final disabilityOptions = [
      'Wheelchair / Mobility',
      'Visual Impairment',
      'Hearing Impairment',
      'Elderly / Crutches',
      'Other Special Needs',
    ];

    final availableFeatures = [
      'General Building Experience',
      '🛗 Entrance Ramp / Step-free',
      '⬆️ Passenger Lift / Elevator',
      '🚻 Accessible Divyang Washroom',
      '💺 Common Lounge / Mess Seating',
      '🧭 Tactile Paths & Braille Signs',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final activeScores = <int>[];
          for (int i = 0; i < 5; i++) {
            if (facilityActive[i]) activeScores.add(scores[i]);
          }
          final computedOverall = activeScores.isEmpty
              ? 0
              : ((activeScores.reduce((a, b) => a + b) / activeScores.length) * 20).round();

          Future<void> pickPhoto(ImageSource source) async {
            final picker = ImagePicker();
            final img = await picker.pickImage(source: source, imageQuality: 70);
            if (img != null) {
              setSheetState(() => photoPath = img.path);
            }
          }

          void showPhotoSourceDialog() {
            showModalBottomSheet(
              context: sheetCtx,
              backgroundColor: const Color(0xFF0F172A),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              builder: (ctx) => SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Select Photo Source',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF00F0FF)),
                        title: const Text('Take Photo with Camera 📸', style: TextStyle(color: Colors.white)),
                        onTap: () {
                          Navigator.pop(ctx);
                          pickPhoto(ImageSource.camera);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF10B981)),
                        title: const Text('Choose from Gallery 🖼️', style: TextStyle(color: Colors.white)),
                        onTap: () {
                          Navigator.pop(ctx);
                          pickPhoto(ImageSource.gallery);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Share Verified Rating',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              p.name,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF134E4A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          '$computedOverall / 100',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00F0FF),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 1. Dual Reviewer Persona: General vs Disabled
                  const Text(
                    'Reviewer Category:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('General Visitor 🧑‍🎓')),
                          selected: userCategory == 'general',
                          selectedColor: const Color(0xFF0F766E),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: userCategory == 'general' ? Colors.white : const Color(0xFF94A3B8),
                          ),
                          onSelected: (val) {
                            if (val) setSheetState(() => userCategory = 'general');
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Divyang / Special Needs ♿')),
                          selected: userCategory == 'disabled',
                          selectedColor: const Color(0xFF0F766E),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: userCategory == 'disabled' ? Colors.white : const Color(0xFF94A3B8),
                          ),
                          onSelected: (val) {
                            if (val) setSheetState(() => userCategory = 'disabled');
                          },
                        ),
                      ),
                    ],
                  ),

                  // If Disabled, pick specific disability type
                  if (userCategory == 'disabled') ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Select Disability / Assistance Type:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF00F0FF)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C2A4A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.3)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: const Color(0xFF1C2A4A),
                          value: disabilityType,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00F0FF)),
                          items: disabilityOptions.map((opt) {
                            return DropdownMenuItem<String>(
                              value: opt,
                              child: Text(opt, style: const TextStyle(fontSize: 13, color: Colors.white)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setSheetState(() => disabilityType = val);
                          },
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Target Feature Selector (e.g. Lift, Washroom, Ramp)
                  const Text(
                    'What specific facility are you rating?',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C2A4A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: const Color(0xFF1C2A4A),
                        value: selectedFeature,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00F0FF)),
                        items: availableFeatures.map((f) {
                          return DropdownMenuItem<String>(
                            value: f,
                            child: Text(f, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setSheetState(() {
                              selectedFeature = val;
                              // Auto-focus category if single facility picked
                              if (val.contains('Ramp')) {
                                for (int i = 0; i < 5; i++) {
                                  facilityActive[i] = i == 0;
                                }
                              } else if (val.contains('Lift')) {
                                for (int i = 0; i < 5; i++) {
                                  facilityActive[i] = i == 1;
                                }
                              } else if (val.contains('Washroom')) {
                                for (int i = 0; i < 5; i++) {
                                  facilityActive[i] = i == 2;
                                }
                              } else if (val.contains('Seating')) {
                                for (int i = 0; i < 5; i++) {
                                  facilityActive[i] = i == 3;
                                }
                              } else if (val.contains('Tactile') || val.contains('Braille')) {
                                for (int i = 0; i < 5; i++) {
                                  facilityActive[i] = i == 4;
                                }
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ),

                  // Floor Selector (if building has floors like Herak Hostel)
                  if (p.floors.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Specific Floor (Optional):',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: const Text('All Floors'),
                              selected: selectedTargetFloor == null,
                              selectedColor: const Color(0xFF0F766E),
                              labelStyle: TextStyle(
                                fontSize: 11,
                                color: selectedTargetFloor == null ? Colors.white : const Color(0xFF94A3B8),
                              ),
                              onSelected: (_) => setSheetState(() => selectedTargetFloor = null),
                            ),
                          ),
                          ...List.generate(p.floors.length, (i) {
                            final f = p.floors[i];
                            final isSel = selectedTargetFloor == i;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text(f.name),
                                selected: isSel,
                                selectedColor: const Color(0xFF0F766E),
                                labelStyle: TextStyle(
                                  fontSize: 11,
                                  color: isSel ? Colors.white : const Color(0xFF94A3B8),
                                ),
                                onSelected: (_) => setSheetState(() => selectedTargetFloor = i),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Rate Facilities (Optional to Pick):',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            final allOn = facilityActive.every((e) => e);
                            for (int i = 0; i < 5; i++) {
                              facilityActive[i] = !allOn;
                            }
                          });
                        },
                        child: Text(
                          facilityActive.every((e) => e) ? 'Deselect All' : 'Select All',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF00F0FF)),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Unchecked facilities will be skipped and will not affect that facility\'s score.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 8),

                  // 5 Categories with Individual Checkbox / Toggle
                  ...List.generate(5, (idx) {
                    final cat = kCategories[idx];
                    final isChecked = facilityActive[idx];

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isChecked ? const Color(0xFF1C2A4A) : const Color(0xFF141E33),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isChecked ? const Color(0xFF00F0FF).withValues(alpha: 0.3) : const Color(0xFF1E293B),
                        ),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isChecked,
                            activeColor: const Color(0xFF00F0FF),
                            checkColor: const Color(0xFF0B132B),
                            onChanged: (val) {
                              setSheetState(() => facilityActive[idx] = val ?? false);
                            },
                          ),
                          SizedBox(
                            width: 110,
                            child: Row(
                              children: [
                                Text(cat.$1, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    cat.$2,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isChecked ? Colors.white : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isChecked) ...[
                            Expanded(
                              child: Slider(
                                value: scores[idx].toDouble(),
                                min: 1,
                                max: 5,
                                divisions: 4,
                                activeColor: const Color(0xFF00F0FF),
                                inactiveColor: const Color(0xFF334155),
                                onChanged: (val) {
                                  setSheetState(() => scores[idx] = val.toInt());
                                },
                              ),
                            ),
                            SizedBox(
                              width: 32,
                              child: Text(
                                '${scores[idx]} ⭐',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00F0FF)),
                              ),
                            ),
                          ] else ...[
                            const Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'Skipped',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 12),
                  TextField(
                    controller: commentCtrl,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Experience & Details',
                      labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      hintText: 'e.g. Lift functioning smooth, washroom clean with sturdy grab bars...',
                      hintStyle: const TextStyle(color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: const Color(0xFF1C2A4A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF334155)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF334155)),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF00F0FF)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.add_a_photo_outlined, size: 18, color: Color(0xFF00F0FF)),
                        label: Text(
                          photoPath == null ? 'Attach Photo (Camera / Gallery)' : 'Change Photo',
                          style: const TextStyle(color: Color(0xFF00F0FF)),
                        ),
                        onPressed: showPhotoSourceDialog,
                      ),
                      if (photoPath != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => setSheetState(() => photoPath = null),
                        ),
                      ],
                    ],
                  ),
                  if (photoPath != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: kIsWeb
                          ? Image.network(photoPath!, height: 80, fit: BoxFit.cover)
                          : Image.file(File(photoPath!), height: 80, fit: BoxFit.cover),
                    ),
                  ],
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0F766E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('Submit Verified Review', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        if (commentCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please write a brief comment! ✍️')),
                          );
                          return;
                        }

                        // Create nullable scores list
                        final finalScores = List<int?>.generate(5, (i) => facilityActive[i] ? scores[i] : null);

                        final user = store.currentUser!;
                        final newReview = Review(
                          scores: finalScores,
                          comment: commentCtrl.text.trim(),
                          user: user.name,
                          userRole: user.isAdmin ? 'Admin' : (userCategory == 'disabled' ? disabilityType : user.needsPreference),
                          photoPath: photoPath,
                          targetTag: selectedFeature,
                          targetFloor: selectedTargetFloor,
                          userCategory: userCategory,
                          disabilityType: userCategory == 'disabled' ? disabilityType : null,
                        );

                        store.addReview(p, newReview);
                        Navigator.pop(sheetCtx);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Feedback submitted! Thank you for contributing to IIT ISM accessibility.'),
                            backgroundColor: Color(0xFF0F766E),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.place;
    final d = store.distanceTo(p);
    final floors = p.floors;
    final currentFloor = floors.isNotEmpty ? floors[_selectedFloorIndex.clamp(0, floors.length - 1)] : null;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(
            p.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'Share campus place',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Share link copied for ${p.name}!')),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF0F766E),
          icon: const Icon(Icons.rate_review_rounded, color: Colors.white),
          label: const Text('Rate Location', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          onPressed: () => _openFeedbackSheet(p),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
          children: [
            // ---- Place Identity Banner ----
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          p.type.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCCFBF1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '🏢 ${p.floorCount} Floors',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F766E),
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (d != null)
                        Text(
                          d < 1000 ? '📍 ${d.round()} m door' : '📍 ${(d / 1000).toStringAsFixed(1)} km door',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F766E)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Campus Coordinates: ${p.lat.toStringAsFixed(4)}° N, ${p.lng.toStringAsFixed(4)}° E',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                  if (p.adminNotice != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Color(0xFFDC2626), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              p.adminNotice!,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF991B1B)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ---- Overall Score Card ----
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    p.color.withValues(alpha: 0.15),
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: p.color.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: p.color, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: p.color.withValues(alpha: 0.25),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            p.reviews.isEmpty ? 'NEW' : '${p.score}',
                            style: TextStyle(
                              fontSize: p.reviews.isEmpty ? 14 : 22,
                              fontWeight: FontWeight.w900,
                              color: p.color,
                            ),
                          ),
                          if (p.reviews.isNotEmpty)
                            Text(
                              '/100',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: p.color.withValues(alpha: 0.8),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(p.tierIcon, color: p.color, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              p.tierLabel,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: p.color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Composite score from ${p.reviews.length} campus verified ratings across all 5 dimensions.',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ---- 🏢 FLOOR-BY-FLOOR ARCHITECTURAL INSPECTOR (HERAK HOSTEL ETC.) ----
            if (floors.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.layers_rounded, color: Color(0xFF0F766E), size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Floor-by-Floor Architecture',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${floors.length} Levels',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Floor Selector Horizontal Tabs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(floors.length, (idx) {
                          final f = floors[idx];
                          final isSelected = _selectedFloorIndex == idx;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(f.name),
                              selected: isSelected,
                              selectedColor: const Color(0xFF0F766E),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF334155),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 12,
                              ),
                              onSelected: (val) {
                                if (val) setState(() => _selectedFloorIndex = idx);
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Current Selected Floor Grid Info
                    if (currentFloor != null) ...[
                      // Floor Key Metrics (Lifts, Washrooms, Ramps)
                      Row(
                        children: [
                          // Lifts Metric Card
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.elevator_rounded, color: Color(0xFF0F766E), size: 20),
                                      SizedBox(width: 4),
                                      Text('Elevators', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${currentFloor.liftsCount} Working Lifts',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  ),
                                  Text(
                                    p.isLiftOperational ? '✅ 24x7 Functional' : '⚠️ Maintenance',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: p.isLiftOperational ? const Color(0xFF10B981) : const Color(0xFFDC2626),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Washrooms Metric Card
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.wc_rounded, color: Color(0xFF0F766E), size: 20),
                                      SizedBox(width: 4),
                                      Text('Restrooms', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${currentFloor.totalWashrooms} Total',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  ),
                                  Text(
                                    '♿ ${currentFloor.accessibleWashrooms} Accessible',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Floor Facilities List
                      const Text(
                        'Floor Accessibility Features:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                      ),
                      const SizedBox(height: 8),
                      ...currentFloor.facilities.map((fac) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    fac,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.3),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // ---- 🤖 AI-GENERATED COMMUNITY SUMMARY CARD ----
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF0FDFA), Color(0xFFCCFBF1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF99F6E4)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F766E).withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFF0F766E), size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'AI Campus Summary',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F766E),
                          letterSpacing: 0.1,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, size: 18, color: Color(0xFF0F766E)),
                        tooltip: 'Regenerate AI Summary',
                        onPressed: _regenerateAiSummary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // AI Tone Chooser
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Standard', 'Divyang User Guide', 'Admin Audit'].map((tone) {
                        final isSelected = _aiTone == tone;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(tone),
                            selected: isSelected,
                            selectedColor: const Color(0xFF0F766E),
                            labelStyle: TextStyle(
                              fontSize: 11,
                              color: isSelected ? Colors.white : const Color(0xFF134E4A),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                            onSelected: (val) {
                              if (val) setState(() => _aiTone = tone);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (_isAiGenerating)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F766E))),
                            SizedBox(width: 10),
                            Text('Synthesizing verified reviews...', style: TextStyle(fontSize: 12, color: Color(0xFF0F766E))),
                          ],
                        ),
                      ),
                    )
                  else
                    Text(
                      p.generateAiSummary(tone: _aiTone),
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: Color(0xFF134E4A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ---- 5 STRUCTURED ACCESSIBILITY DIMENSIONS ----
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Campus Accessibility Metrics',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Community ratings across 5 key dimensions (1 - 5 Scale)',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(5, (i) {
                    final cat = kCategories[i];
                    final avgVal = p.avg(i);
                    final progressVal = avgVal / 5.0;
                    final isGood = avgVal >= 3.5;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(cat.$1, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  cat.$2,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              Text(
                                avgVal > 0 ? '${avgVal.toStringAsFixed(1)} / 5.0' : 'No data',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isGood
                                      ? const Color(0xFF0F766E)
                                      : (avgVal > 0 ? const Color(0xFFD97706) : const Color(0xFF94A3B8)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progressVal,
                              minHeight: 8,
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isGood
                                    ? const Color(0xFF10B981)
                                    : (avgVal > 0 ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ---- COMMUNITY REVIEWS STREAM ----
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Campus Reviews (${p.reviews.length})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                if (p.photoCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '📷 ${p.photoCount} Photo-Proof',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Review Filter Tabs: All, Divyang/Special Needs, General
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: Text('All (${p.reviews.length})'),
                    selected: _reviewFilter == 'all',
                    selectedColor: const Color(0xFF0F766E),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _reviewFilter == 'all' ? Colors.white : const Color(0xFF475569),
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _reviewFilter = 'all');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('♿ Divyang Reviews '),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: _reviewFilter == 'disabled' ? Colors.white24 : const Color(0xFFCCFBF1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${p.specialReviews.length}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _reviewFilter == 'disabled' ? Colors.white : const Color(0xFF0F766E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    selected: _reviewFilter == 'disabled',
                    selectedColor: const Color(0xFF0F766E),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _reviewFilter == 'disabled' ? Colors.white : const Color(0xFF475569),
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _reviewFilter = 'disabled');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('🧑‍🎓 General (${p.generalReviews.length})'),
                    selected: _reviewFilter == 'general',
                    selectedColor: const Color(0xFF0F766E),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _reviewFilter == 'general' ? Colors.white : const Color(0xFF475569),
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _reviewFilter = 'general');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            () {
              final filteredReviews = _reviewFilter == 'all'
                  ? p.reviews
                  : (_reviewFilter == 'disabled' ? p.specialReviews : p.generalReviews);

              if (filteredReviews.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.rate_review_outlined, size: 40, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 10),
                        Text(
                          _reviewFilter == 'disabled'
                              ? 'No Divyang reviews yet for this venue'
                              : 'No reviews yet in this category',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Be the first visitor to evaluate and help others!',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.tonal(
                          onPressed: () => _openFeedbackSheet(p),
                          child: const Text('Add Review ✍️'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: filteredReviews.reversed.map((r) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: r.isSpecialNeeds ? const Color(0xFF14B8A6).withValues(alpha: 0.5) : const Color(0xFFE2E8F0),
                          width: r.isSpecialNeeds ? 1.5 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: r.isSpecialNeeds ? const Color(0xFFCCFBF1) : const Color(0xFFF1F5F9),
                                child: Text(
                                  r.isSpecialNeeds ? '♿' : (r.user.isNotEmpty ? r.user[0].toUpperCase() : 'U'),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          r.user,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        if (r.isSpecialNeeds) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFCCFBF1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              r.disabilityType ?? 'Special Needs',
                                              style: const TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF0F766E),
                                              ),
                                            ),
                                          ),
                                        ] else if (r.userRole != null) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: r.userRole == 'Admin' ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              r.userRole!,
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: r.userRole == 'Admin' ? const Color(0xFFDC2626) : const Color(0xFF475569),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      '${r.time.day}/${r.time.month}/${r.time.year}',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  r.validAvg > 0 ? 'Avg ${r.validAvg.toStringAsFixed(1)} ⭐' : 'Feedback',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                                ),
                              ),
                            ],
                          ),
                          // Target facility tag or floor badge
                          if (r.targetTag != null || r.targetFloor != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                if (r.targetTag != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFBFDBFE)),
                                    ),
                                    child: Text(
                                      r.targetTag!,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1D4ED8),
                                      ),
                                    ),
                                  ),
                                if (r.targetFloor != null) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0FDF4),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFBBF7D0)),
                                    ),
                                    child: Text(
                                      r.targetFloor == 0 ? 'Ground Floor' : 'Floor ${r.targetFloor}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF15803D),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                          const SizedBox(height: 10),
                          Text(
                            r.comment,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: List.generate(5, (idx) {
                              final score = idx < r.scores.length ? r.scores[idx] : null;
                              if (score == null) return const SizedBox.shrink();
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Text(
                                  '${kCategories[idx].$1} $score ⭐',
                                  style: const TextStyle(fontSize: 10, color: Color(0xFF475569)),
                                ),
                              );
                            }),
                          ),
                          if (r.photoPath != null) ...[
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: const EdgeInsets.all(16),
                                    child: Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: _photo(r.photoPath!, h: 400),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  _photo(r.photoPath!, h: 180),
                                  Container(
                                    margin: const EdgeInsets.all(8),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.zoom_in_rounded, color: Colors.white, size: 14),
                                        SizedBox(width: 4),
                                        Text('Tap to expand', style: TextStyle(color: Colors.white, fontSize: 10)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          // Community verified helpfulness footer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    r.isSpecialNeeds ? Icons.accessibility_new_rounded : Icons.verified_user_outlined,
                                    size: 14,
                                    color: const Color(0xFF10B981),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    r.isSpecialNeeds ? 'Special Needs Verified Review' : 'Campus Verified Review',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () => store.upvoteReview(p, r),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.thumb_up_alt_outlined, size: 13, color: Color(0xFF475569)),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Helpful (${r.upvotes})',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )).toList(),
              );
            }(),
          ],
        ),
      ),
    );
  }
}
