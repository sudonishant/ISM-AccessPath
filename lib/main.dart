// ============================================================
// AccessPath v2 — IIT (ISM) Dhanbad Accessibility Feedback App
// ============================================================
// main.dart — App Entry Point, Premium Theme & Navigation Shell
// ============================================================

import 'package:flutter/material.dart';
import 'models.dart';
import 'store.dart';
import 'pages/explore_page.dart';
import 'pages/map_page.dart';
import 'pages/add_place_page.dart';
import 'pages/profile_page.dart';
import 'pages/detail_page.dart';
import 'pages/ai_chat_page.dart';
import 'pages/auth_page.dart';
import 'pages/admin_report_page.dart';

final navKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await store.load();
  runApp(const AccessPathApp());
}

class AccessPathApp extends StatelessWidget {
  const AccessPathApp({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    const primaryCyan = Color(0xFF00F0FF); // Electric Cyan Accent
    const bgDark = Color(0xFF0B132B); // Deep Space Navy
    const surfaceDark = Color(0xFF131F37); // Dark Slate Surface

    return MaterialApp(
      title: 'AccessPath — IIT (ISM) Dhanbad',
      debugShowCheckedModeBanner: false,
      navigatorKey: navKey,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgDark,
        colorScheme: const ColorScheme.dark(
          primary: primaryCyan,
          secondary: Color(0xFF10B981),
          surface: surfaceDark,
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Color(0xFF0F172A),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFF1E293B), width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 68,
          backgroundColor: const Color(0xFF0F172A),
          elevation: 8,
          indicatorColor: const Color(0xFF00F0FF).withValues(alpha: 0.2),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? const Color(0xFF00F0FF) : const Color(0xFF64748B),
            );
          }),
        ),
      ),
      home: const Shell(),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int tab = 0;

  final pages = const [
    ExplorePage(),
    MapPage(),
    AddPlacePage(),
    AIChatPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    store.onDwell = _showDwellNotification;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      store.startWatch();
      if (store.isFirstTimeUser) {
        _showFirstTimeOnboardingDialog();
      }
    });
  }

  void _showFirstTimeOnboardingDialog() {
    final ctx = navKey.currentContext;
    if (ctx == null) return;

    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF00F0FF), width: 1.2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/logo/accesspath_logo.png',
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.accessible_forward, size: 50, color: Color(0xFF00F0FF)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Welcome to AccessPath',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'IIT (ISM) Dhanbad Accessibility System',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF00F0FF)),
              ),
              const SizedBox(height: 14),
              const Text(
                'Discover barrier-free campus routes, inspect elevator & washroom status across all 5 floors of Herak Hostel, and contribute verified reviews for Divyangjan community.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8), height: 1.4),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF334155)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        store.completeOnboarding();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Explore First', style: TextStyle(color: Color(0xFF94A3B8))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0F766E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        store.completeOnboarding();
                        Navigator.pop(ctx);
                        Navigator.push(
                          ctx,
                          MaterialPageRoute(builder: (_) => const AuthPage()),
                        );
                      },
                      child: const Text('Login / Setup 👤', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDwellNotification(Place p) {
    final ctx = navKey.currentContext;
    if (ctx == null) return;

    showDialog(
      context: ctx,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF14B8A6).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 18),
              const Text(
                'Feedback Time! 📍',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Aap "${p.name}" ke paas hain. Kya is jagah ki accessibility ka quick review share karenge? Dusre visitors ki badi madad hogi!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475569),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Baad Me'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0F766E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          ctx,
                          MaterialPageRoute(builder: (_) => DetailPage(p)),
                        );
                      },
                      child: const Text('Rate Now ✍️'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeWeb = constraints.maxWidth >= 840;

        if (isLargeWeb) {
          // React/Next.js-style Premium Modern Dashboard Layout for Web / Desktop
          return Scaffold(
            body: Row(
              children: [
                // Modern Cyberpunk Web Sidebar matching AI Assistant
                Container(
                  width: 270,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F172A),
                    border: Border(
                      right: BorderSide(color: Color(0xFF1E293B), width: 1.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sidebar Brand Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/logo/accesspath_logo.png',
                                width: 42,
                                height: 42,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00F0FF).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.accessible_forward_rounded, color: Color(0xFF00F0FF), size: 24),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AccessPath',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'IIT (ISM) Dhanbad',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF00F0FF),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFF1E293B)),
                      const SizedBox(height: 16),

                      // Navigation Items
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Column(
                          children: [
                            _webNavTile(0, Icons.explore_outlined, Icons.explore_rounded, 'Explore Places'),
                            _webNavTile(1, Icons.map_outlined, Icons.map_rounded, 'Campus Map'),
                            _webNavTile(2, Icons.add_location_alt_outlined, Icons.add_location_alt_rounded, 'Contribute Venue'),
                            _webNavTile(3, Icons.auto_awesome_outlined, Icons.auto_awesome, 'AI Assistant 🤖'),
                            _webNavTile(4, Icons.person_outline_rounded, Icons.person_rounded, 'Profile & XP 🏆'),
                            const SizedBox(height: 8),
                            // Admin Audit Portal Direct Button in Sidebar
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AdminReportPage()),
                                );
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.3)),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.assessment_rounded, size: 20, color: Color(0xFF00F0FF)),
                                    SizedBox(width: 12),
                                    Text(
                                      'Audit Reports & Admin',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Campus Quick Info in Sidebar Footer
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131F37),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Live Campus Telemetry',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF10B981)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Herakles Hostel: 5 Floors, 2 Lifts, 10 Washrooms verified.',
                              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), height: 1.35),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content Area
                Expanded(
                  child: Container(
                    color: const Color(0xFF0B132B),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: IndexedStack(index: tab, children: pages),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Mobile / Tablet Screen Layout
        return Scaffold(
          body: IndexedStack(index: tab, children: pages),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              border: Border(top: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: NavigationBar(
              selectedIndex: tab,
              onDestinationSelected: (i) => setState(() => tab = i),
              backgroundColor: const Color(0xFF0F172A),
              indicatorColor: const Color(0xFF00F0FF).withValues(alpha: 0.2),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined, color: Color(0xFF64748B)),
                  selectedIcon: Icon(Icons.explore_rounded, color: Color(0xFF00F0FF)),
                  label: 'Explore',
                ),
                NavigationDestination(
                  icon: Icon(Icons.map_outlined, color: Color(0xFF64748B)),
                  selectedIcon: Icon(Icons.map_rounded, color: Color(0xFF00F0FF)),
                  label: 'Map',
                ),
                NavigationDestination(
                  icon: Icon(Icons.add_location_alt_outlined, color: Color(0xFF64748B)),
                  selectedIcon: Icon(Icons.add_location_alt_rounded, color: Color(0xFF00F0FF)),
                  label: 'Add Place',
                ),
                NavigationDestination(
                  icon: Icon(Icons.auto_awesome_outlined, color: Color(0xFF64748B)),
                  selectedIcon: Icon(Icons.auto_awesome, color: Color(0xFF00F0FF)),
                  label: 'AI Helper',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded, color: Color(0xFF64748B)),
                  selectedIcon: Icon(Icons.person_rounded, color: Color(0xFF00F0FF)),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _webNavTile(int index, IconData unselectedIcon, IconData selectedIcon, String label) {
    final isSelected = tab == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => tab = index),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF00F0FF).withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: isSelected ? Border.all(color: const Color(0xFF00F0FF), width: 1.2) : null,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? selectedIcon : unselectedIcon,
                  size: 20,
                  color: isSelected ? const Color(0xFF00F0FF) : const Color(0xFF64748B),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? const Color(0xFF00F0FF) : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
