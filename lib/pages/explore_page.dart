// ============================================================
// explore_page.dart — PAGE 1: Discovery, Search & Requirements Filter
// EV Smart Mobility Cockpit & Telemetry HUD Redesign
// ============================================================

import 'package:flutter/material.dart';
import '../models.dart';
import '../store.dart';
import '../widgets/glass_container.dart';
import 'detail_page.dart';
import 'auth_page.dart';
import 'ai_chat_page.dart';
import 'map_page.dart';
import 'vision_detector_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final Set<int> needs = {}; // Selected accessibility category filters
  String query = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final filteredList = store.places
            .where((p) =>
                p.name.toLowerCase().contains(query.toLowerCase()) &&
                needs.every((i) => p.avg(i) >= 3.5))
            .toList()
          ..sort((a, b) => (store.distanceTo(a) ?? 1e9)
              .compareTo(store.distanceTo(b) ?? 1e9));

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final brandTitleColor = isDark ? Colors.white : const Color(0xFF0F172A);
        final brandSubColor = isDark ? const Color(0xFF00F0FF) : const Color(0xFF0F766E);
        final searchBg = isDark ? const Color(0xFF131F37) : Colors.white;
        final searchBorder = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
        final searchHintColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
        final searchTextColor = isDark ? Colors.white : const Color(0xFF0F172A);

        return Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- Top Brand Header ----
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    'assets/logo/accesspath_logo.png',
                                    width: 32,
                                    height: 32,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF00F0FF).withValues(alpha: 0.15) : const Color(0xFFCCFBF1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.accessible_forward_rounded,
                                        color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0F766E),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'AccessPath',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                      color: brandTitleColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'IIT (ISM) Dhanbad',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: brandSubColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Targeted In-App Notifications Bell
                          GestureDetector(
                            onTap: () => _showNotificationsSheet(context, isDark),
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF00F0FF).withValues(alpha: 0.4) : const Color(0xFFCBD5E1),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    store.unreadNotificationsCount > 0
                                        ? Icons.notifications_active_rounded
                                        : Icons.notifications_none_rounded,
                                    size: 13,
                                    color: store.unreadNotificationsCount > 0
                                        ? const Color(0xFFFF6B2B)
                                        : (isDark ? const Color(0xFF00F0FF) : const Color(0xFF0F766E)),
                                  ),
                                  if (store.unreadNotificationsCount > 0) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF4D4F),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${store.unreadNotificationsCount}',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ] else ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      'Alerts',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? Colors.white : const Color(0xFF334155),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          // Cloud Sync Indicator
                          GestureDetector(
                            onTap: () {
                              store.syncWithBackend();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('🔄 Backend server & Firebase sync running...'),
                                  duration: Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: store.isOnline ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: store.isOnline ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    store.isSyncing
                                        ? Icons.sync_rounded
                                        : (store.isOnline ? Icons.cloud_done_rounded : Icons.cloud_off_rounded),
                                    size: 13,
                                    color: store.isOnline ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    store.isSyncing
                                        ? 'Sync'
                                        : (store.isOnline ? 'Cloud' : 'Offline'),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: store.isOnline ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AIChatPage()),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF14B8A6).withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.auto_awesome, size: 12, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'AI Helper',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AuthPage()),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: store.isAdmin ? const Color(0xFFFEE2E2) : const Color(0xFFCCFBF1),
                                shape: BoxShape.circle,
                                border: Border.all(color: store.isAdmin ? const Color(0xFFDC2626) : const Color(0xFF0F766E)),
                              ),
                              child: Text(
                                store.currentUser?.avatarEmoji ?? '👤',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ---- Search Field with Voice Search ----
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: searchBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: searchBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        Icon(Icons.search_rounded, color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF00796B), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            style: TextStyle(color: searchTextColor),
                            decoration: InputDecoration(
                              hintText: 'Search campus building, ramp, lift...',
                              hintStyle: TextStyle(color: searchHintColor, fontSize: 14),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onChanged: (v) => setState(() => query = v),
                          ),
                        ),
                        if (query.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.clear, size: 18, color: searchHintColor),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => query = '');
                            },
                          ),
                        // Voice Search Button
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🎙️ Voice Search: Bol kar campus building search karein...'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF00F0FF).withValues(alpha: 0.15) : const Color(0xFFCCFBF1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.mic_rounded,
                              size: 18,
                              color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF00796B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ---- Requirements Filter Section ----
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: Row(
                    children: [
                      Text(
                        'Filter by Needs',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (needs.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0F766E),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${needs.length} Active',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const Spacer(),
                      if (needs.isNotEmpty)
                        GestureDetector(
                          onTap: () => setState(() => needs.clear()),
                          child: Text(
                            'Reset',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0F766E),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Filter Chips Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    children: List.generate(5, (i) {
                      final c = kCategories[i];
                      final isSelected = needs.contains(i);
                      final chipBg = isDark ? const Color(0xFF131F37) : Colors.white;
                      final chipBorder = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
                      final selectedChipBg = isDark ? const Color(0xFF00F0FF) : const Color(0xFF0F766E);
                      final selectedChipText = isDark ? const Color(0xFF0B132B) : Colors.white;
                      final unselectedChipText = isDark ? Colors.white : const Color(0xFF334155);

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          avatar: Text(c.$1, style: const TextStyle(fontSize: 14)),
                          label: Text(c.$2),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? selectedChipText : unselectedChipText,
                          ),
                          selected: isSelected,
                          selectedColor: selectedChipBg,
                          backgroundColor: chipBg,
                          checkmarkColor: selectedChipText,
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected ? selectedChipBg : chipBorder,
                            ),
                          ),
                          onSelected: (s) => setState(() {
                            if (s) {
                              needs.add(i);
                            } else {
                              needs.remove(i);
                            }
                          }),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 6),

                // ---- Scrollable Campus Places Feed ----
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      // ---- Campus Accessibility Radar Overview ----
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                                  : [Colors.white, const Color(0xFFF8FAFC)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? const Color(0xFF00F0FF).withValues(alpha: 0.25) : const Color(0xFFE2E8F0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
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
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF00F0FF).withValues(alpha: 0.15) : const Color(0xFFCCFBF1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.radar_rounded,
                                      size: 16,
                                      color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0F766E),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Campus Accessibility Radar',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                                    ),
                                    child: const Text(
                                      'LIVE AUDITED',
                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF10B981)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildRadarStatTile(
                                      icon: Icons.business_rounded,
                                      count: '${store.places.length}',
                                      label: 'Venues',
                                      isDark: isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: _buildRadarStatTile(
                                      icon: Icons.elevator_rounded,
                                      count: '${store.places.fold<int>(0, (acc, p) => acc + p.totalLifts)}',
                                      label: 'Lifts',
                                      isDark: isDark,
                                      onTap: () => setState(() => query = 'lift'),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: _buildRadarStatTile(
                                      icon: Icons.accessible_forward_rounded,
                                      count: '${store.places.fold<int>(0, (acc, p) => acc + p.totalAccessibleWashrooms)}',
                                      label: 'Restrooms',
                                      isDark: isDark,
                                      onTap: () => setState(() => query = 'washroom'),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: _buildRadarStatTile(
                                      icon: Icons.shield_rounded,
                                      count: '${store.activeHazards.length}',
                                      label: 'Hazards',
                                      isDark: isDark,
                                      accentColor: const Color(0xFFEF4444),
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const VisionDetectorPage()),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // ---- AI Vision & Animal Deterrent Scanner Launcher ----
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const VisionDetectorPage()),
                          ),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [const Color(0xFF131D38), const Color(0xFF0F172A)]
                                    : [const Color(0xFFEFF6FF), const Color(0xFFE0E7FF)],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFF00F0FF).withValues(alpha: isDark ? 0.4 : 0.3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00F0FF).withValues(alpha: isDark ? 0.12 : 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF00F0FF), Color(0xFF3B82F6)],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            'AI Vision & Animal Buzzer',
                                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'LIVE OPENCV',
                                              style: TextStyle(color: Color(0xFFEF4444), fontSize: 8, fontWeight: FontWeight.w900),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Real-time camera detection for stray dogs, monkeys & cattle with acoustic repellent buzzer & strobe light.',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF00F0FF)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // ---- 6. Place List Header ----
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Places (${filteredList.length})',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              store.myPos != null ? 'Sorted by Distance' : 'Default Order',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ---- 7. Places Cards ----
                      if (filteredList.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF131F37),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.search_off_rounded,
                                    size: 48,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No places match criteria',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Try relaxing your filter requirements or searching for a different keyword.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                ),
                                const SizedBox(height: 16),
                                if (needs.isNotEmpty || query.isNotEmpty)
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF00F0FF),
                                      side: const BorderSide(color: Color(0xFF00F0FF)),
                                    ),
                                    icon: const Icon(Icons.refresh, size: 16),
                                    label: const Text('Clear Filters'),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      setState(() {
                                        query = '';
                                        needs.clear();
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...filteredList.map((p) => Padding(
                              padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
                              child: _buildPlaceCard(context, p),
                            )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceCard(BuildContext context, Place p) {
    final d = store.distanceTo(p);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final divColor = isDark ? Colors.white10 : const Color(0xFFE2E8F0);
    final isCharging = p.isChargingStation;

    // Clean Campus Distance
    final distanceLabel = d != null ? (d < 1000 ? '${d.round()}m' : '${(d / 1000).toStringAsFixed(1)}km') : 'Nearby';

    return GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(16),
      borderColor: isCharging
          ? const Color(0xFF00F0FF).withValues(alpha: 0.5)
          : null,
      surfaceColor: isCharging && isDark
          ? const Color(0xFF091428)
          : null,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailPage(p)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Type Badge, Battery Draw Chip & Radial Score / Fast Dock Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isCharging
                                ? const Color(0xFF00F0FF).withValues(alpha: 0.18)
                                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE0F2FE)),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isCharging
                                  ? const Color(0xFF00F0FF)
                                  : (isDark
                                      ? const Color(0xFF38BDF8).withValues(alpha: 0.3)
                                      : const Color(0xFF0284C7).withValues(alpha: 0.3)),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isCharging) ...[
                                const Icon(Icons.flash_on_rounded, size: 11, color: Color(0xFF00F0FF)),
                                const SizedBox(width: 3),
                              ],
                              Text(
                                isCharging ? 'EV CHARGING DOCK' : p.type.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isCharging
                                      ? const Color(0xFF00F0FF)
                                      : (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7)),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (p.isCustom) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B2B).withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFFF6B2B)),
                            ),
                            child: const Text(
                              '🆕 Public',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFFF6B2B),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: nameColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(p.tierIcon, size: 13, color: isCharging ? const Color(0xFF00F0FF) : p.color),
                        const SizedBox(width: 4),
                        Text(
                          isCharging ? 'Rapid 220V Verified Bay' : p.tierLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isCharging ? const Color(0xFF00F0FF) : p.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Radial Score Badge with glowing border
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: (isCharging ? const Color(0xFF00F0FF) : p.color).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (isCharging ? const Color(0xFF00F0FF) : p.color).withValues(alpha: 0.7),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isCharging ? const Color(0xFF00F0FF) : p.color).withValues(alpha: 0.25),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isCharging
                            ? '⚡ 4P'
                            : (p.reviews.isEmpty ? 'NEW' : '${p.score}'),
                        style: TextStyle(
                          fontSize: isCharging ? 11 : (p.reviews.isEmpty ? 11 : 15),
                          fontWeight: FontWeight.w900,
                          color: isCharging ? const Color(0xFF00F0FF) : p.color,
                        ),
                      ),
                      if (!isCharging && p.reviews.isNotEmpty)
                        Text(
                          '/100',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: p.color.withValues(alpha: 0.8),
                          ),
                        ),
                      if (isCharging)
                        const Text(
                          '220V',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF00F0FF),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Divider(height: 1, color: divColor),
          const SizedBox(height: 10),

          // Facilities & Washroom Indicators Row
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              // Step-Free Access / Venue Type Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: (p.hasRamp ? const Color(0xFF10B981) : const Color(0xFF38BDF8)).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (p.hasRamp ? const Color(0xFF10B981) : const Color(0xFF38BDF8)).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      p.hasRamp ? Icons.accessible_forward_rounded : Icons.location_on_rounded,
                      size: 12,
                      color: p.hasRamp ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      p.hasRamp ? 'Step-Free Ramp' : distanceLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: p.hasRamp ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
                      ),
                    ),
                  ],
                ),
              ),

              // Washrooms summary
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wc_rounded, size: 12, color: Color(0xFF38BDF8)),
                    const SizedBox(width: 4),
                    Text(
                      '${p.totalAccessibleWashrooms} Acc / ${p.totalWashrooms} Toilets',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF38BDF8)),
                    ),
                  ],
                ),
              ),

              // Lifts summary
              if (p.hasLift)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.elevator_rounded, size: 12, color: Color(0xFF10B981)),
                      const SizedBox(width: 4),
                      Text(
                        '${p.totalLifts} Lifts Active',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
                      ),
                    ],
                  ),
                ),

              // Ramp indicator
              if (p.hasRamp)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E599).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF00E599).withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.accessible_rounded, size: 12, color: Color(0xFF00E599)),
                      SizedBox(width: 4),
                      Text(
                        'Step-Free Ramp',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF00E599)),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Bottom Row: Distance, Reviews count & Direct Navigate HUD CTA Button
          Row(
            children: [
              if (d != null) ...[
                const Icon(Icons.near_me_rounded, size: 13, color: Color(0xFFFF6B2B)),
                const SizedBox(width: 4),
                Text(
                  d < 1000 ? '${d.round()} m away' : '${(d / 1000).toStringAsFixed(1)} km away',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFF6B2B),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Text(
                '${p.reviews.length} reviews',
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
              const Spacer(),
              // Quick EV Route Navigation Button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MapPage(initialPlace: p, autoStartNav: true),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF00F0FF).withValues(alpha: 0.15)
                        : const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0284C7),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.navigation_rounded,
                        size: 11,
                        color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0284C7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isCharging ? 'Charge' : 'Navigate',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadarStatTile({
    required IconData icon,
    required String count,
    required String label,
    required bool isDark,
    Color? accentColor,
    VoidCallback? onTap,
  }) {
    final effectiveColor = accentColor ?? (isDark ? const Color(0xFF00F0FF) : const Color(0xFF0F766E));
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: accentColor != null
                ? accentColor.withValues(alpha: 0.35)
                : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 14, color: effectiveColor),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: accentColor ?? (isDark ? Colors.white : const Color(0xFF0F172A)),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final notifs = store.notifications;
            final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
            final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B2B).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.notifications_active_rounded, color: Color(0xFFFF6B2B), size: 18),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Campus Notifications',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                        if (notifs.isNotEmpty)
                          TextButton(
                            onPressed: () => store.markNotificationsRead(),
                            child: const Text('Mark all read', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF00F0FF))),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (notifs.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 36),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.notifications_none_rounded, size: 40, color: textSecondary.withValues(alpha: 0.4)),
                              const SizedBox(height: 10),
                              Text(
                                'No notifications yet',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'When someone likes or interacts with your reviews, you will receive a notification here!',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, color: textSecondary),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: notifs.length,
                          separatorBuilder: (_, __) => Divider(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                          itemBuilder: (context, i) {
                            final n = notifs[i];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: n.isRead
                                      ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9))
                                      : const Color(0xFFFF6B2B).withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.thumb_up_alt_rounded,
                                  size: 16,
                                  color: n.isRead ? textSecondary : const Color(0xFFFF6B2B),
                                ),
                              ),
                              title: Text(
                                n.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: n.isRead ? FontWeight.w600 : FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 2),
                                  Text(
                                    n.message,
                                    style: TextStyle(fontSize: 12, color: textSecondary),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    n.timeAgo,
                                    style: TextStyle(fontSize: 10, color: textSecondary.withValues(alpha: 0.7)),
                                  ),
                                ],
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
        );
      },
    );
  }
}

