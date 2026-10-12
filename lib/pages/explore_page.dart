// ============================================================
// explore_page.dart — PAGE 1: Discovery, Search & Requirements Filter
// ============================================================

import 'package:flutter/material.dart';
import '../models.dart';
import '../store.dart';
import 'detail_page.dart';
import 'auth_page.dart';
import 'ai_chat_page.dart';

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
                                Text(
                                  'AccessPath',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                    color: brandTitleColor,
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
                          // Theme Toggle Button (Dark 🌙 / Light ☀️)
                          GestureDetector(
                            onTap: () => store.toggleTheme(),
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF00F0FF).withValues(alpha: 0.4) : const Color(0xFFF59E0B),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                    size: 13,
                                    color: isDark ? const Color(0xFFF59E0B) : const Color(0xFF6366F1),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isDark ? 'Light' : 'Dark',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : const Color(0xFFB45309),
                                    ),
                                  ),
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

                // ---- Google Stitch Style: Active Accessibility Mode Bar ----
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00796B), Color(0xFF10B981)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.accessible_rounded, color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text('Wheelchair Route • Verified', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            SizedBox(width: 4),
                            Icon(Icons.check_circle, color: Colors.white, size: 13),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('🔊 Screen Reader & Audio Guide Beacon enabled')),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF131F37) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.record_voice_over_rounded, color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF00796B), size: 15),
                              const SizedBox(width: 5),
                              Text('Audio Guide', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 11, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('🔇 Sensory Quiet Path & Low Noise Route selected')),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF131F37) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.hearing_rounded, color: Color(0xFFF59E0B), size: 15),
                              const SizedBox(width: 5),
                              Text('Sensory Quiet', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 11, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // ---- Modern Tactile Search Field with Voice Search & Beacon Button ----
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
                        // Voice Search Button (Google Material Stitch Style)
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

                // ---- Stitch UI: Live Operational Beacon Card (Herakles Hostel) ----
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF0F2B26), const Color(0xFF132A38)]
                            : [const Color(0xFFECFDF5), const Color(0xFFF0FDFA)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.5),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Color(0xFF10B981), blurRadius: 6, spreadRadius: 1),
                            ],
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
                                    'Herakles Hostel Lifts',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('Ground to 5th Floor • Active', style: TextStyle(color: Color(0xFF10B981), fontSize: 9, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Verified today • Wide 42" door, Braille keypad & voice announce',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.elevator_rounded, color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF00796B), size: 24),
                      ],
                    ),
                  ),
                ),

                // ---- Requirements Filter Section ----
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
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

                // ---- Place List Header ----
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Places (${filteredList.length})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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

                // ---- Places List View ----
                Expanded(
                  child: filteredList.isEmpty
                      ? Center(
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
                                const Text(
                                  'No places match criteria',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
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
                      : LayoutBuilder(
                          builder: (context, boxConstraints) {
                            final isWide = boxConstraints.maxWidth > 700;

                            if (isWide) {
                              return GridView.builder(
                                padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.55,
                                ),
                                itemCount: filteredList.length,
                                itemBuilder: (context, i) {
                                  final p = filteredList[i];
                                  return _buildPlaceCard(context, p);
                                },
                              );
                            }

                            return ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                              itemCount: filteredList.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, i) {
                                final p = filteredList[i];
                                return _buildPlaceCard(context, p);
                              },
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
  }

  Widget _buildPlaceCard(BuildContext context, Place p) {
    final d = store.distanceTo(p);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF131F37) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final chipBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final nameColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final divColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailPage(p)),
      ),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cardBorder),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title, Type badge & Score Circle
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
                              color: chipBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              p.type.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0F766E),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          if (p.isCustom) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFF59E0B)),
                              ),
                              child: const Text(
                                '🆕 Community',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFBBF24),
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
                          fontWeight: FontWeight.w700,
                          color: nameColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p.tierLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: p.color,
                        ),
                      ),
                    ],
                  ),
                ),

                // Radial Score Badge
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: p.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: p.color.withValues(alpha: 0.5), width: 2),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          p.reviews.isEmpty ? 'NEW' : '${p.score}',
                          style: TextStyle(
                            fontSize: p.reviews.isEmpty ? 11 : 16,
                            fontWeight: FontWeight.w800,
                            color: p.color,
                          ),
                        ),
                        if (p.reviews.isNotEmpty)
                          Text(
                            '/100',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: p.color.withValues(alpha: 0.8),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Divider(height: 1, color: divColor),
            const SizedBox(height: 12),

            // Middle Row: 5 Category Accessibility Badges Preview
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: List.generate(5, (idx) {
                final avgVal = p.avg(idx);
                final isAvailable = avgVal >= 3.5;
                final cat = kCategories[idx];

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isAvailable ? const Color(0xFF10B981) : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(cat.$1, style: const TextStyle(fontSize: 11)),
                      const SizedBox(width: 3),
                      Text(
                        avgVal > 0 ? avgVal.toStringAsFixed(1) : '—',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isAvailable ? const Color(0xFF10B981) : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),

            const SizedBox(height: 12),

            // Bottom Row: Distance, Reviews count & Photo count
            Row(
              children: [
                if (d != null) ...[
                  const Icon(Icons.near_me_outlined, size: 14, color: Color(0xFF00F0FF)),
                  const SizedBox(width: 4),
                  Text(
                    d < 1000 ? '${d.round()} m away' : '${(d / 1000).toStringAsFixed(1)} km away',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00F0FF),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                const Icon(Icons.chat_bubble_outline_rounded, size: 13, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Text(
                  '${p.reviews.length} reviews',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
                if (p.photoCount > 0) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.photo_camera_outlined, size: 13, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 4),
                  Text(
                    '${p.photoCount} photos',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                ],
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: Color(0xFF64748B),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
