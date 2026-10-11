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
  Widget build(BuildContext context) {
    const primaryCyan = Color(0xFF00F0FF); // Electric Cyan Accent
    const primaryTeal = Color(0xFF0F766E); // Heritage Teal for light mode
    const bgDark = Color(0xFF0B132B); // Deep Space Navy
    const surfaceDark = Color(0xFF131F37); // Dark Slate Surface
    const bgLight = Color(0xFFF8FAFC); // Clean Slate 50
    const surfaceLight = Colors.white;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        return MaterialApp(
          title: 'AccessPath — IIT (ISM) Dhanbad',
          debugShowCheckedModeBanner: false,
          navigatorKey: navKey,
          themeMode: store.themeMode,
          // Light Theme
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: bgLight,
            colorScheme: const ColorScheme.light(
              primary: primaryTeal,
              secondary: Color(0xFF059669),
              surface: surfaceLight,
              onSurface: Color(0xFF0F172A),
              outline: Color(0xFFE2E8F0),
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: false,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: Colors.white,
              titleTextStyle: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
              iconTheme: IconThemeData(color: Color(0xFF0F172A)),
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              color: surfaceLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
              margin: EdgeInsets.zero,
            ),
            navigationBarTheme: NavigationBarThemeData(
              height: 68,
              backgroundColor: Colors.white,
              elevation: 8,
              indicatorColor: const Color(0xFF0F766E).withValues(alpha: 0.15),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                final isSelected = states.contains(WidgetState.selected);
                return TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF0F766E) : const Color(0xFF64748B),
                );
              }),
            ),
          ),
          // Dark Theme
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: bgDark,
            colorScheme: const ColorScheme.dark(
              primary: primaryCyan,
              secondary: Color(0xFF10B981),
              surface: surfaceDark,
              onSurface: Colors.white,
              outline: Color(0xFF1E293B),
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
      },
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

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final sidebarBg = isDark ? const Color(0xFF0F172A) : Colors.white;
        final sidebarBorder = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
        final contentBg = isDark ? const Color(0xFF0B132B) : const Color(0xFFF1F5F9);
        final cardBg = isDark ? const Color(0xFF131F37) : const Color(0xFFF8FAFC);
        final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);

        if (isLargeWeb) {
          // React/Next.js-style Premium Modern Dashboard Layout for Web / Desktop
          return Scaffold(
            body: Row(
              children: [
                // Modern Web Sidebar matching AI Assistant
                Container(
                  width: 270,
                  decoration: BoxDecoration(
                    color: sidebarBg,
                    border: Border(
                      right: BorderSide(color: sidebarBorder, width: 1.2),
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AccessPath',
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                      color: titleColor,
                                    ),
                                  ),
                                  const Text(
                                    'IIT (ISM) Dhanbad',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F766E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: sidebarBorder),
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
                                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: isDark ? const Color(0xFF00F0FF).withValues(alpha: 0.3) : const Color(0xFFCBD5E1)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.assessment_rounded, size: 20, color: Color(0xFF0F766E)),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Audit Reports & Admin',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: titleColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Theme Switcher Tile in Sidebar
                            InkWell(
                              onTap: () => store.toggleTheme(),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF131F37) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF00F0FF).withValues(alpha: 0.4) : const Color(0xFFF59E0B),
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                      size: 19,
                                      color: isDark ? const Color(0xFFF59E0B) : const Color(0xFF6366F1),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        isDark ? 'Switch to Light Mode ☀️' : 'Switch to Dark Mode 🌙',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: titleColor,
                                        ),
                                      ),
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
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: sidebarBorder),
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
                            Text(
                              'Herakles Hostel: 5 Floors, 2 Lifts, 10 Washrooms verified.',
                              style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), height: 1.35),
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
                    color: contentBg,
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
        final navBarBg = isDark ? const Color(0xFF0F172A) : Colors.white;
        final navBarBorder = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
        final navSelectedColor = isDark ? const Color(0xFF00F0FF) : const Color(0xFF0F766E);
        final navUnselectedColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

        return Scaffold(
          body: IndexedStack(index: tab, children: pages),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: navBarBg,
              border: Border(top: BorderSide(color: navBarBorder)),
            ),
            child: NavigationBar(
              selectedIndex: tab,
              onDestinationSelected: (i) => setState(() => tab = i),
              backgroundColor: navBarBg,
              indicatorColor: navSelectedColor.withValues(alpha: 0.18),
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined, color: navUnselectedColor),
                  selectedIcon: Icon(Icons.explore_rounded, color: navSelectedColor),
                  label: 'Explore',
                ),
                NavigationDestination(
                  icon: Icon(Icons.map_outlined, color: navUnselectedColor),
                  selectedIcon: Icon(Icons.map_rounded, color: navSelectedColor),
                  label: 'Map',
                ),
                NavigationDestination(
                  icon: Icon(Icons.add_location_alt_outlined, color: navUnselectedColor),
                  selectedIcon: Icon(Icons.add_location_alt_rounded, color: navSelectedColor),
                  label: 'Add Place',
                ),
                NavigationDestination(
                  icon: Icon(Icons.auto_awesome_outlined, color: navUnselectedColor),
                  selectedIcon: Icon(Icons.auto_awesome, color: navSelectedColor),
                  label: 'AI Helper',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded, color: navUnselectedColor),
                  selectedIcon: Icon(Icons.person_rounded, color: navSelectedColor),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? const Color(0xFF00F0FF) : const Color(0xFF0F766E);
    final inactiveColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

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
              color: isSelected ? activeColor.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: isSelected ? Border.all(color: activeColor, width: 1.2) : null,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? selectedIcon : unselectedIcon,
                  size: 20,
                  color: isSelected ? activeColor : inactiveColor,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? activeColor : inactiveColor,
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
