// ============================================================
// add_place_page.dart — PAGE 4: Add New / Unknown Location
// ============================================================

import 'package:flutter/material.dart';
import '../models.dart';
import '../store.dart';
import 'profile_page.dart';

class AddPlacePage extends StatefulWidget {
  final double? lat, lng;
  const AddPlacePage({super.key, this.lat, this.lng});

  @override
  State<AddPlacePage> createState() => _AddPlacePageState();
}

class _AddPlacePageState extends State<AddPlacePage> {
  final nameCtrl = TextEditingController();
  String type = 'Academic';
  double? lat, lng;
  bool gettingGps = false;

  @override
  void initState() {
    super.initState();
    lat = widget.lat;
    lng = widget.lng;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _useMyLocation() async {
    setState(() => gettingGps = true);
    await store.startWatch();
    setState(() {
      lat = store.myPos?.latitude;
      lng = store.myPos?.longitude;
      gettingGps = false;
    });

    if (lat == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📍 Location detect nahi ho payi. Please check GPS settings.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Public Place'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile check banner
          if (store.profile == null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_rounded, color: Color(0xFFD97706), size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile Required',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF92400E)),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Spam prevent karne ke liye sirf verified profile wale users hi naye places add kar sakte hain.',
                          style: TextStyle(fontSize: 12, color: Color(0xFFB45309)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    ),
                    child: const Text('Create'),
                  ),
                ],
              ),
            ),

          // Card 1: Venue Details
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.business_rounded, color: Color(0xFF0F766E), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Place Details',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Place / Building Name',
                    hintText: 'e.g. New Academic Complex, Canteen 2...',
                    prefixIcon: const Icon(Icons.edit_location_alt_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Venue Category',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kPlaceTypes.map((t) {
                    final isSelected = type == t;
                    return ChoiceChip(
                      label: Text(t),
                      selected: isSelected,
                      selectedColor: const Color(0xFF0F766E),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF334155),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => type = t);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Card 2: Location & Coordinates
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.pin_drop_rounded, color: Color(0xFF0F766E), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Geographic Location',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        lat != null ? Icons.check_circle_rounded : Icons.pending_outlined,
                        color: lat != null ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lat == null
                                  ? 'Coordinates not set yet'
                                  : '📍 ${lat!.toStringAsFixed(5)}° N, ${lng!.toStringAsFixed(5)}° E',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              widget.lat != null
                                  ? 'Captured from map tap location'
                                  : (lat != null ? 'Captured via real-time GPS' : 'Tap GPS button below or long-press map'),
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: gettingGps
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location_rounded, size: 18),
                    label: const Text('Capture Current GPS Coordinates'),
                    onPressed: gettingGps ? null : _useMyLocation,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Primary Submit Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.add_location_alt_rounded),
              label: const Text(
                'Register & Publish Location',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                if (store.profile == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🔒 Pehle profile create karein!')),
                  );
                  return;
                }
                if (nameCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Place ka naam zaroori hai! ✍️')),
                  );
                  return;
                }
                if (lat == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('📍 Location capture karein (GPS ya map se)!')),
                  );
                  return;
                }

                final placeName = nameCtrl.text.trim();
                store.addPlace(
                  Place(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: placeName,
                    type: type,
                    lat: lat!,
                    lng: lng!,
                    isCustom: true,
                  ),
                );

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ "$placeName" added to AccessPath! Community can now rate it.'),
                    backgroundColor: const Color(0xFF0F766E),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
