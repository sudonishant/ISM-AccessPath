// ============================================================
// profile_page.dart — User Profile, Contributor XP & Activity History
// Styled with Cyberpunk Dark Theme matching AI Assistant
// ============================================================

import 'package:flutter/material.dart';
import '../models.dart';
import '../store.dart';
import 'auth_page.dart';
import 'admin_report_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final user = store.currentUser;
        
        // Find all contributions made by this user
        final userReviews = <({Place place, Review review})>[];
        int photoCount = 0;
        for (final p in store.places) {
          for (final r in p.reviews) {
            if (r.user.toLowerCase() == (user?.name.toLowerCase() ?? '') ||
                (user != null && r.user.toLowerCase().contains(user.name.toLowerCase().split(' ').first))) {
              userReviews.add((place: p, review: r));
              if (r.photoPath != null) photoCount++;
            }
          }
        }

        final myReviewsCount = userReviews.length;
        final myPlacesCount = store.places.where((p) => p.isCustom).length;

        // Calculate Gamified Contribution XP & Tier
        final xp = (myReviewsCount * 50) + (myPlacesCount * 100) + (photoCount * 30);
        String contributorTier;
        Color tierColor;
        double progressToNext;

        if (xp >= 300) {
          contributorTier = 'Level 4: Campus Champion 🏆';
          tierColor = const Color(0xFFF59E0B);
          progressToNext = 1.0;
        } else if (xp >= 150) {
          contributorTier = 'Level 3: Accessibility Scout 🧭';
          tierColor = const Color(0xFF00F0FF);
          progressToNext = (xp - 150) / 150;
        } else if (xp >= 50) {
          contributorTier = 'Level 2: Campus Contributor 🌟';
          tierColor = const Color(0xFF10B981);
          progressToNext = (xp - 50) / 100;
        } else {
          contributorTier = 'Level 1: Campus Explorer 🚶';
          tierColor = const Color(0xFF94A3B8);
          progressToNext = xp / 50;
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final pageBg = isDark ? const Color(0xFF0B132B) : const Color(0xFFF1F5F9);
        final appBarBg = isDark ? const Color(0xFF0F172A) : Colors.white;
        final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
        final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        final accentColor = isDark ? const Color(0xFF00F0FF) : const Color(0xFF0F766E);

        return Scaffold(
          backgroundColor: pageBg,
          appBar: AppBar(
            backgroundColor: appBarBg,
            elevation: 0,
            title: Text(
              'Campus Community Profile',
              style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            actions: [
              TextButton.icon(
                icon: Icon(Icons.swap_horiz_rounded, size: 18, color: accentColor),
                label: Text('Switch Account', style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthPage()),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User Identity Card with Glowing Gradient
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: user?.isAdmin == true
                        ? [const Color(0xFF991B1B), const Color(0xFFEF4444)]
                        : [const Color(0xFF0F172A), const Color(0xFF132238)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: user?.isAdmin == true
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF00F0FF).withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (user?.isAdmin == true ? const Color(0xFFEF4444) : const Color(0xFF00F0FF))
                          .withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: const Color(0xFF1E293B),
                      child: Text(user?.avatarEmoji ?? '🧑‍🎓', style: const TextStyle(fontSize: 34)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.name ?? 'Campus Member',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      user?.email ?? 'IIT (ISM) Dhanbad',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00F0FF).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF00F0FF)),
                          ),
                          child: Text(
                            user?.isAdmin == true ? '🛡️ Campus Administrator' : '🎓 ${user?.needsPreference ?? "Student"}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00F0FF)),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Roll: ${user?.rollNo ?? "22JE0123"}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFFE2E8F0), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Contributor Gamification & XP Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131F37) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: tierColor.withValues(alpha: 0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 10,
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
                        Row(
                          children: [
                            Icon(Icons.military_tech_rounded, color: tierColor, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              contributorTier,
                              style: TextStyle(color: tierColor, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: tierColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$xp XP',
                            style: TextStyle(color: tierColor, fontSize: 13, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progressToNext.clamp(0.05, 1.0),
                        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(tierColor),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Every verified review gives +50 XP · Photo attachment gives +30 XP · New campus venue gives +100 XP',
                      style: TextStyle(color: textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Contribution Statistics Grid (Reviews, Places, Photos, Impact)
              Text(
                'My Campus Contributions:',
                style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildStatTile(
                    label: 'Reviews Given',
                    count: '$myReviewsCount',
                    icon: Icons.rate_review_rounded,
                    color: const Color(0xFF00F0FF),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 10),
                  _buildStatTile(
                    label: 'Venues Added',
                    count: '$myPlacesCount',
                    icon: Icons.add_location_alt_rounded,
                    color: const Color(0xFFF59E0B),
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildStatTile(
                    label: 'Photos Proofs',
                    count: '$photoCount',
                    icon: Icons.photo_camera_rounded,
                    color: const Color(0xFF10B981),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 10),
                  _buildStatTile(
                    label: 'Students Helped',
                    count: '${(myReviewsCount * 14) + 25}',
                    icon: Icons.volunteer_activism_rounded,
                    color: const Color(0xFFB224EF),
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Admin Report Portal Quick Access Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00F0FF).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.assessment_rounded, color: Color(0xFF00F0FF), size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Campus Audit Reports & Summaries',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'View aggregated reviews, export reports & lift statuses.',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF00F0FF),
                        foregroundColor: const Color(0xFF0B132B),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AdminReportPage()),
                        );
                      },
                      child: const Text('Open Portal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Detailed Contribution History List
              Text(
                'Recent Contribution Activity:',
                style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              if (userReviews.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF131F37) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(Icons.history_rounded, color: textSecondary, size: 36),
                      const SizedBox(height: 8),
                      Text('No reviews submitted yet.', style: TextStyle(color: textSecondary, fontSize: 13)),
                      Text('Visit Herakles Hostel or Central Library to submit your first feedback!', style: TextStyle(color: textSecondary, fontSize: 11), textAlign: TextAlign.center),
                    ],
                  ),
                )
              else
                ...userReviews.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF131F37) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.place.name,
                                style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.review.comment.isNotEmpty ? item.review.comment : 'Verified Accessibility Review',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '★ ${item.review.overallScore.toStringAsFixed(1)}',
                            style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatTile({
    required String label,
    required String count,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131F37) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? color.withValues(alpha: 0.3) : const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold)),
                Icon(icon, color: color, size: 18),
              ],
            ),
            const SizedBox(height: 6),
            Text(count, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 20, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}
