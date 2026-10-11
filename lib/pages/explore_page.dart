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
                                        color: const Color(0xFFCCFBF1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.accessible_forward_rounded,
                                        color: Color(0xFF0F766E),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'AccessPath',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'IIT (ISM) Dhanbad',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              store.syncWithBackend();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('🔄 Backend server sync running...'),
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

                // ---- Modern Search Field ----
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search campus building, library, canteen...',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0F766E), size: 22),
                        suffixIcon: query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => query = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onChanged: (v) => setState(() => query = v),
                    ),
                  ),
                ),

                // ---- Requirements Filter Section ----
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                  child: Row(
                    children: [
                      const Text(
                        'Filter by Needs',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (needs.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F766E),
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
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              color: Color(0xFF0F766E),
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
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          avatar: Text(c.$1, style: const TextStyle(fontSize: 14)),
                          label: Text(c.$2),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : const Color(0xFF334155),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF0F766E),
                          backgroundColor: Colors.white,
                          checkmarkColor: Colors.white,
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFF0F766E) : const Color(0xFFE2E8F0),
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
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        store.myPos != null ? 'Sorted by Distance' : 'Default Order',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
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
                                    color: Color(0xFFF1F5F9),
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
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Try relaxing your filter requirements or searching for a different keyword.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                ),
                                const SizedBox(height: 16),
                                if (needs.isNotEmpty || query.isNotEmpty)
                                  OutlinedButton.icon(
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

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailPage(p)),
      ),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              p.type.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF475569),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          if (p.isCustom) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '🆕 Community',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        p.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
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
                    color: p.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: p.color.withValues(alpha: 0.4), width: 2),
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
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
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
                    color: isAvailable
                        ? const Color(0xFFECFDF5)
                        : (avgVal > 0 ? const Color(0xFFFFFBEB) : const Color(0xFFF8FAFC)),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isAvailable
                          ? const Color(0xFFA7F3D0)
                          : (avgVal > 0 ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0)),
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
                          color: isAvailable
                              ? const Color(0xFF065F46)
                              : (avgVal > 0 ? const Color(0xFF92400E) : const Color(0xFF94A3B8)),
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
                  const Icon(Icons.near_me_outlined, size: 14, color: Color(0xFF0F766E)),
                  const SizedBox(width: 4),
                  Text(
                    d < 1000 ? '${d.round()} m away' : '${(d / 1000).toStringAsFixed(1)} km away',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                const Icon(Icons.chat_bubble_outline_rounded, size: 13, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  '${p.reviews.length} reviews',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                if (p.photoCount > 0) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.photo_camera_outlined, size: 13, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    '${p.photoCount} photos',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
