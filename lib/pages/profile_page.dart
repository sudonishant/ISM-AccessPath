// ============================================================
// profile_page.dart — User Profile, Role Badge & Campus Admin Panel
// ============================================================

import 'package:flutter/material.dart';
import '../store.dart';
import 'auth_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _noticeCtrl = TextEditingController();

  @override
  void dispose() {
    _noticeCtrl.dispose();
    super.dispose();
  }

  void _showAdminNoticeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Publish Campus Notice'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select a venue (e.g., Herak Hostel) and publish an official estate / accessibility alert:',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noticeCtrl,
              decoration: const InputDecoration(
                labelText: 'Advisory Text',
                hintText: 'e.g. Lift 1 under routine service till 5 PM.',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            onPressed: () {
              if (_noticeCtrl.text.trim().isNotEmpty) {
                store.setAdminNotice('herak', _noticeCtrl.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notice posted to Herak Hostel!')),
                );
              }
            },
            child: const Text('Publish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final user = store.currentUser;
        final myReviews = store.places
            .expand((p) => p.reviews)
            .where((r) => r.user == user?.name)
            .length;
        final myPlaces = store.places.where((p) => p.isCustom).length;
        final herakPlace = store.places.firstWhere((p) => p.id == 'herak', orElse: () => store.places.first);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Campus Community Profile'),
            actions: [
              TextButton.icon(
                icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                label: const Text('Switch Account'),
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
            padding: const EdgeInsets.all(20),
            children: [
              // Profile Identity Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: user?.isAdmin == true
                        ? [const Color(0xFFDC2626), const Color(0xFFEF4444)]
                        : [const Color(0xFF0F766E), const Color(0xFF14B8A6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: (user?.isAdmin == true ? const Color(0xFFDC2626) : const Color(0xFF0F766E))
                          .withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Text(user?.avatarEmoji ?? '🧑‍🎓', style: const TextStyle(fontSize: 36)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.name ?? 'Guest Visitor',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      user?.email ?? 'IIT (ISM) Dhanbad',
                      style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.9)),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        user?.isAdmin == true ? '🛡️ Campus Administrator' : '🎓 ${user?.needsPreference ?? "Student"}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ---- ADMIN CONTROLS PANEL (IF LOGGED IN AS ADMIN) ----
              if (user?.isAdmin == true) ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDC2626).withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.admin_panel_settings_rounded, color: Color(0xFFDC2626), size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Campus Infrastructure Controls',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF991B1B)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Toggle Herak Hostel Lifts
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Herak Hostel Lifts Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text(
                          herakPlace.isLiftOperational ? 'Both 2 elevators fully operational' : 'Elevator maintenance alert active',
                          style: TextStyle(
                            fontSize: 11,
                            color: herakPlace.isLiftOperational ? const Color(0xFF10B981) : const Color(0xFFDC2626),
                          ),
                        ),
                        value: herakPlace.isLiftOperational,
                        activeThumbColor: const Color(0xFF10B981),
                        onChanged: (val) => store.toggleLiftStatus('herak', val),
                      ),
                      const Divider(height: 1),

                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFDC2626),
                                side: const BorderSide(color: Color(0xFFDC2626)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.campaign_outlined, size: 18),
                              label: const Text('Post Campus Advisory'),
                              onPressed: () => _showAdminNoticeDialog(context),
                            ),
                          ),
                          if (herakPlace.adminNotice != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                              tooltip: 'Clear notice',
                              onPressed: () => store.setAdminNotice('herak', null),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Contribution Statistics
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.rate_review_rounded, color: Color(0xFF0F766E), size: 24),
                          const SizedBox(height: 10),
                          Text(
                            '$myReviews',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                          ),
                          const Text('My Verified Ratings', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.add_location_alt_rounded, color: Color(0xFFD97706), size: 24),
                          const SizedBox(height: 10),
                          Text(
                            '$myPlaces',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                          ),
                          const Text('Campus Places Added', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Smart Dwell Alert Info Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF99F6E4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFCCFBF1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.radar_rounded, color: Color(0xFF0F766E), size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Smart Dwell Feedback System',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F766E),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Agar aap Herak Hostel ya Central Library ke 150m radius ke andar 2+ minute rukte hain, to app khud automatic prompt karti hai verified feedback lene ke liye.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF134E4A),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Switch or Logout action
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.manage_accounts_outlined),
                  label: const Text('Switch Role (New User / Student / Admin)'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AuthPage()),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
