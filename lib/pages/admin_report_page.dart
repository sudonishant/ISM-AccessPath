// ============================================================
// admin_report_page.dart — Campus Accessibility Audit & Review Reports
// Comprehensive analytics, full review breakdown & estate advisories
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models.dart';
import '../store.dart';

class AdminReportPage extends StatefulWidget {
  const AdminReportPage({super.key});

  @override
  State<AdminReportPage> createState() => _AdminReportPageState();
}

class _AdminReportPageState extends State<AdminReportPage> {
  final String _selectedBuildingFilter = 'All';
  String _selectedCategoryFilter = 'All'; // All, Divyang, General, Photo
  final _noticeCtrl = TextEditingController();
  final _serverUrlCtrl = TextEditingController();
  String _noticeBuildingId = 'herak';

  @override
  void dispose() {
    _noticeCtrl.dispose();
    _serverUrlCtrl.dispose();
    super.dispose();
  }

  void _showServerConfigDialog(BuildContext context) {
    _serverUrlCtrl.text = store.customBackendUrl ?? '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF00F0FF), width: 1),
        ),
        title: const Row(
          children: [
            Icon(Icons.cloud_sync_rounded, color: Color(0xFF00F0FF)),
            SizedBox(width: 8),
            Text('Cloud Backend / Vercel', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set Vercel or Custom Serverless Endpoint:',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _serverUrlCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'https://accesspath-backend.vercel.app',
                hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Current Base URL: ${store.serverBaseUrl}',
              style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              store.setCustomBackendUrl(null);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reset to default backend')),
              );
            },
            child: const Text('Reset Default', style: TextStyle(color: Color(0xFFEF4444))),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF00F0FF),
              foregroundColor: const Color(0xFF0B132B),
            ),
            onPressed: () {
              final url = _serverUrlCtrl.text.trim();
              store.setCustomBackendUrl(url.isEmpty ? null : url);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Backend URL updated: ${store.serverBaseUrl}'),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
            child: const Text('Save & Sync', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showNoticeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF00F0FF), width: 1),
        ),
        title: const Row(
          children: [
            Icon(Icons.campaign_rounded, color: Color(0xFF00F0FF)),
            SizedBox(width: 8),
            Text('Publish Estate Notice', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Target Facility:',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _noticeBuildingId,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: store.places.map((p) => DropdownMenuItem(
                  value: p.id,
                  child: Text(p.name, style: const TextStyle(fontSize: 13, color: Colors.white)),
                )).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => _noticeBuildingId = val);
                  }
                },
              ),
              const SizedBox(height: 14),
              const Text(
                'Notice / Advisory Text:',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _noticeCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g. Lift 1 undergoing sensor repair until 4 PM.',
                  hintStyle: const TextStyle(color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF00F0FF),
              foregroundColor: const Color(0xFF0B132B),
            ),
            onPressed: () {
              if (_noticeCtrl.text.trim().isNotEmpty) {
                store.setAdminNotice(_noticeBuildingId, _noticeCtrl.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Official campus notice published successfully!'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              }
            },
            child: const Text('Publish Advisory', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _exportAuditReportModal(BuildContext context) {
    final allReviews = <Map<String, dynamic>>[];
    for (final p in store.places) {
      for (final r in p.reviews) {
        allReviews.add({
          'place': p.name,
          'category': p.type,
          'user': r.user,
          'userCategory': r.userCategory,
          'disability': r.disabilityType ?? 'None',
          'score': r.overallScore.toStringAsFixed(1),
          'ramp': r.stepFree?.toStringAsFixed(1) ?? 'N/A',
          'lift': r.lift?.toStringAsFixed(1) ?? 'N/A',
          'washroom': r.washroom?.toStringAsFixed(1) ?? 'N/A',
          'seating': r.seating?.toStringAsFixed(1) ?? 'N/A',
          'wayfinding': r.wayfinding?.toStringAsFixed(1) ?? 'N/A',
          'comment': r.comment,
          'hasPhoto': r.photoPath != null,
          'date': r.date.toIso8601String().split('T').first,
        });
      }
    }

    final totalReviews = allReviews.length;
    final divyangReviews = allReviews.where((r) => r['userCategory'] == 'disabled').length;
    final photoCount = allReviews.where((r) => r['hasPhoto'] == true).length;
    final avgScore = store.places.isEmpty
        ? 0
        : (store.places.map((p) => p.score).reduce((a, b) => a + b) / store.places.length).round();

    final reportText = '''
======================================================
IIT (ISM) DHANBAD — CAMPUS ACCESSIBILITY AUDIT REPORT
Generated: ${DateTime.now().toLocal().toString().split('.').first}
Status: OFFICIAL ESTATE & INFRASTRUCTURE REPORT
======================================================

EXECUTIVE SUMMARY:
• Total Monitored Landmarks: ${store.places.length}
• Total Verified Feedback Submissions: $totalReviews
• Divyang / Special Needs Reviews: $divyangReviews (${totalReviews > 0 ? ((divyangReviews / totalReviews) * 100).toStringAsFixed(1) : 0}%)
• Photo-Proofed Inspections: $photoCount
• Campus Overall Accessibility Index: $avgScore / 100

CRITICAL INFRASTRUCTURE STATUS:
${store.places.map((p) => '• ${p.name}: Score ${p.score}/100 | Lifts: ${p.isLiftOperational ? "OPERATIONAL" : "ALERT: MAINTENANCE REQUIRED"}${p.adminNotice != null ? " [Notice: ${p.adminNotice}]" : ""}').join('\n')}

RECENT DETAILED AUDITS:
${allReviews.take(10).map((r) => '[${r['date']}] ${r['place']} | User: ${r['user']} (${r['userCategory'] == "disabled" ? "♿ ${r['disability']}" : "Student"}) | Score: ${r['score']}/5 | "${r['comment']}"').join('\n')}

======================================================
End of Official Campus Accessibility Report
======================================================
''';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Audit Report & Export',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'IIT (ISM) Campus Accessibility Intelligence',
                        style: TextStyle(color: Color(0xFF00F0FF), fontSize: 12),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_all_rounded, color: Color(0xFF00F0FF)),
                    tooltip: 'Copy Report to Clipboard',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: reportText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📋 Audit report copied to clipboard!'),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B132B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: SelectableText(
                      reportText,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Color(0xFFE2E8F0),
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF00F0FF),
                    foregroundColor: const Color(0xFF0B132B),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('Done / Dismiss', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        // Collect all reviews with parent place
        final allEntries = <({Place place, Review review})>[];
        for (final p in store.places) {
          for (final r in p.reviews) {
            allEntries.add((place: p, review: r));
          }
        }

        // Apply filters
        final filteredEntries = allEntries.where((item) {
          if (_selectedBuildingFilter != 'All' && item.place.id != _selectedBuildingFilter) {
            return false;
          }
          if (_selectedCategoryFilter == 'Divyang' && item.review.userCategory != 'disabled') {
            return false;
          }
          if (_selectedCategoryFilter == 'General' && item.review.userCategory == 'disabled') {
            return false;
          }
          if (_selectedCategoryFilter == 'Photo' && item.review.photoPath == null) {
            return false;
          }
          return true;
        }).toList();

        final totalReviews = allEntries.length;
        final divyangCount = allEntries.where((e) => e.review.userCategory == 'disabled').length;
        final photoCount = allEntries.where((e) => e.review.photoPath != null).length;
        final avgCampusScore = store.places.isEmpty
            ? 0
            : (store.places.map((p) => p.score).reduce((a, b) => a + b) / store.places.length).round();

        final brokenLiftsCount = store.places.where((p) => !p.isLiftOperational).length;

        return Scaffold(
          backgroundColor: const Color(0xFF0B132B),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0F172A),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Row(
              children: [
                Icon(Icons.shield_rounded, color: Color(0xFF00F0FF), size: 22),
                SizedBox(width: 8),
                Text(
                  'Admin Audit Portal',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.cloud_sync_rounded, color: Color(0xFF10B981)),
                tooltip: 'Vercel / Cloud Backend Settings',
                onPressed: () => _showServerConfigDialog(context),
              ),
              IconButton(
                icon: const Icon(Icons.summarize_rounded, color: Color(0xFF00F0FF)),
                tooltip: 'Export Audit Report',
                onPressed: () => _exportAuditReportModal(context),
              ),
              IconButton(
                icon: const Icon(Icons.campaign_rounded, color: Color(0xFFF59E0B)),
                tooltip: 'Post Campus Notice',
                onPressed: () => _showNoticeDialog(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Hero Banner
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F0FF).withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Campus Estate & Infrastructure Oversight',
                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF10B981)),
                          ),
                          child: const Text('LIVE AUDIT', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Aggregated community reviews, floor-by-floor accessibility audits, and real-time maintenance telemetry across IIT (ISM) Dhanbad.',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF00F0FF),
                              foregroundColor: const Color(0xFF0B132B),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            icon: const Icon(Icons.file_download_outlined, size: 18),
                            label: const Text('Generate Audit Report', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            onPressed: () => _exportAuditReportModal(context),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFF59E0B),
                              side: const BorderSide(color: Color(0xFFF59E0B)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            icon: const Icon(Icons.notification_add_outlined, size: 18),
                            label: const Text('Post Advisory', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            onPressed: () => _showNoticeDialog(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // KPI Metrics Row
              Row(
                children: [
                  _buildKpiCard(
                    title: 'Total Reviews',
                    value: '$totalReviews',
                    subtitle: 'Across all venues',
                    color: const Color(0xFF00F0FF),
                    icon: Icons.rate_review_rounded,
                  ),
                  const SizedBox(width: 10),
                  _buildKpiCard(
                    title: 'Divyang Audits',
                    value: '$divyangCount',
                    subtitle: '${totalReviews > 0 ? ((divyangCount / totalReviews) * 100).toStringAsFixed(0) : 0}% of all input',
                    color: const Color(0xFFB224EF),
                    icon: Icons.accessible_forward_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildKpiCard(
                    title: 'Campus Score',
                    value: '$avgCampusScore/100',
                    subtitle: 'Overall Barrier-Free',
                    color: const Color(0xFF10B981),
                    icon: Icons.speed_rounded,
                  ),
                  const SizedBox(width: 10),
                  _buildKpiCard(
                    title: 'Photo Proofs',
                    value: '$photoCount',
                    subtitle: 'Verified images',
                    color: const Color(0xFF38BDF8),
                    icon: Icons.photo_camera_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Critical Alerts Box (if any lift broken)
              if (brokenLiftsCount > 0) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF450A0A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEF4444)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 26),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '⚠️ $brokenLiftsCount Facility Lift Alert Active',
                              style: const TextStyle(color: Color(0xFFFECACA), fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const Text(
                              'One or more elevator complexes reported under maintenance. Check building status below.',
                              style: TextStyle(color: Color(0xFFFCA5A5), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Filter Controls
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF131F37),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter Audit Log:',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    // Category Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['All', 'Divyang', 'General', 'Photo'].map((cat) {
                          final isSelected = _selectedCategoryFilter == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                cat == 'Divyang' ? '♿ Divyang ($divyangCount)' :
                                cat == 'Photo' ? '📸 Photo Proofs ($photoCount)' : cat,
                              ),
                              selected: isSelected,
                              selectedColor: const Color(0xFF00F0FF),
                              backgroundColor: const Color(0xFF1E293B),
                              labelStyle: TextStyle(
                                color: isSelected ? const Color(0xFF0B132B) : Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 11,
                              ),
                              onSelected: (_) => setState(() => _selectedCategoryFilter = cat),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Review Breakdown Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Audit Log (${filteredEntries.length} Submissions)',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Latest First',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Reviews List
              if (filteredEntries.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: const Text('No audits match the selected filter.', style: TextStyle(color: Color(0xFF64748B))),
                )
              else
                ...filteredEntries.map((e) => _buildAuditEntryCard(e.place, e.review)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF131F37),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600)),
                Icon(icon, color: color, size: 18),
              ],
            ),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditEntryCard(Place place, Review review) {
    final isDivyang = review.userCategory == 'disabled';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF131F37),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDivyang
              ? const Color(0xFFB224EF).withValues(alpha: 0.4)
              : const Color(0xFF1E293B),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User avatar
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDivyang ? const Color(0xFFB224EF) : const Color(0xFF00F0FF),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(isDivyang ? '♿' : '🧑‍🎓', style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.user,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(width: 6),
                        if (isDivyang)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB224EF).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              review.disabilityType ?? 'Divyang',
                              style: const TextStyle(color: Color(0xFFE0A7FF), fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF00F0FF)),
                        const SizedBox(width: 2),
                        Text(
                          place.name,
                          style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Text(
                          review.timeAgo,
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Overall score badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: Text(
                  '★ ${review.overallScore.toStringAsFixed(1)}',
                  style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Selective Ratings Breakdown Badges
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (review.stepFree != null)
                _buildRatingChip('🛗 Ramp', review.stepFree!),
              if (review.lift != null)
                _buildRatingChip('⬆️ Lift', review.lift!),
              if (review.washroom != null)
                _buildRatingChip('🚻 Washroom', review.washroom!),
              if (review.seating != null)
                _buildRatingChip('💺 Seating', review.seating!),
              if (review.wayfinding != null)
                _buildRatingChip('🧭 Signage', review.wayfinding!),
            ],
          ),

          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '"${review.comment}"',
              style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12, fontStyle: FontStyle.italic, height: 1.3),
            ),
          ],

          if (review.photoPath != null) ...[
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 14),
                SizedBox(width: 4),
                Text(
                  'Photo Verified Inspection Attached',
                  style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingChip(String label, num score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Text(
        '$label: ${score.toDouble().toStringAsFixed(1)}',
        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}
