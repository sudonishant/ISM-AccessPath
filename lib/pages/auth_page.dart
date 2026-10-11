// ============================================================
// auth_page.dart — 3-Tier Authentication (New User, Login, Admin)
// ============================================================

import 'package:flutter/material.dart';
import '../store.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // New User Controllers
  final _signupNameCtrl = TextEditingController();
  final _signupRollCtrl = TextEditingController();
  final _signupEmailCtrl = TextEditingController();
  final _signupPassCtrl = TextEditingController();
  String _selectedPersona = 'Wheelchair User';
  String _selectedEmoji = '🧑‍🦽';

  // Already Login Controllers
  final _loginIdCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();

  // Admin Portal Controllers
  final _adminEmailCtrl = TextEditingController(text: 'admin@iitism.ac.in');
  final _adminPinCtrl = TextEditingController(text: '1926');

  final List<(String, String)> _personas = [
    ('🧑‍🦽', 'Wheelchair User'),
    ('👩‍🦯', 'Visual Assistance'),
    ('🧏', 'Hearing Assistance'),
    ('🧑‍🎓', 'General Student'),
    ('👨‍🏫', 'Faculty / Staff'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signupNameCtrl.dispose();
    _signupRollCtrl.dispose();
    _signupEmailCtrl.dispose();
    _signupPassCtrl.dispose();
    _loginIdCtrl.dispose();
    _loginPassCtrl.dispose();
    _adminEmailCtrl.dispose();
    _adminPinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AccessPath Account'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF0F766E),
          labelColor: const Color(0xFF0F766E),
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.person_add_alt_1_rounded), text: 'New User'),
            Tab(icon: Icon(Icons.login_rounded), text: 'Log In'),
            Tab(icon: Icon(Icons.admin_panel_settings_rounded), text: 'Admin Portal'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNewUserTab(),
          _buildLoginTab(),
          _buildAdminTab(),
        ],
      ),
    );
  }

  // ---------------- 1. NEW USER (SIGN UP) ----------------
  Widget _buildNewUserTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Join IIT (ISM) Access Network',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 4),
        const Text(
          'Create your student / campus profile to share verified feedback and add locations.',
          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 16),

        // Persona Chooser
        const Text(
          'Select Your Accessibility Persona:',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _personas.map((p) {
              final isSelected = _selectedPersona == p.$2;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  avatar: Text(p.$1),
                  label: Text(p.$2),
                  selected: isSelected,
                  selectedColor: const Color(0xFF0F766E),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF334155),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  onSelected: (val) {
                    if (val) {
                      setState(() {
                        _selectedPersona = p.$2;
                        _selectedEmoji = p.$1;
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _signupNameCtrl,
          decoration: InputDecoration(
            labelText: 'Full Name',
            hintText: 'e.g. Aman Sharma',
            prefixIcon: const Icon(Icons.badge_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _signupRollCtrl,
          decoration: InputDecoration(
            labelText: 'Admission / Roll Number',
            hintText: 'e.g. 22JE0123',
            prefixIcon: const Icon(Icons.school_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _signupEmailCtrl,
          decoration: InputDecoration(
            labelText: 'IIT ISM Email',
            hintText: 'student@iitism.ac.in',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _signupPassCtrl,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 20),

        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0F766E),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: () async {
            if (_signupNameCtrl.text.trim().isEmpty || _signupRollCtrl.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill name and roll number! ✍️')),
              );
              return;
            }

            await store.signup(
              name: _signupNameCtrl.text.trim(),
              rollNo: _signupRollCtrl.text.trim(),
              email: _signupEmailCtrl.text.trim(),
              password: _signupPassCtrl.text.trim(),
              persona: _selectedPersona,
              emoji: _selectedEmoji,
            );

            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Welcome, ${store.currentUser!.name}! Account created.')),
              );
            }
          },
          child: const Text('Create New Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ),
      ],
    );
  }

  // ---------------- 2. ALREADY USER (LOG IN) ----------------
  Widget _buildLoginTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Welcome Back',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 4),
        const Text(
          'Login with your IIT (ISM) credentials or use a quick 1-tap demo student profile.',
          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 20),

        TextField(
          controller: _loginIdCtrl,
          decoration: InputDecoration(
            labelText: 'Roll No or Email',
            hintText: 'e.g. 22JE0123',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _loginPassCtrl,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 20),

        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0F766E),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: () async {
            final id = _loginIdCtrl.text.trim().isEmpty ? '22JE0123' : _loginIdCtrl.text.trim();
            await store.login(identifier: id, password: _loginPassCtrl.text);

            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Logged in as ${store.currentUser!.name}')),
              );
            }
          },
          child: const Text('Log In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ),
        const SizedBox(height: 24),

        // Quick 1-Click Demo Profiles
        const Divider(color: Color(0xFFE2E8F0)),
        const SizedBox(height: 12),
        const Text(
          'Or 1-Tap Quick Demo Login:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          icon: const Text('🧑‍🦽', style: TextStyle(fontSize: 18)),
          label: const Text('Login as Aman (Wheelchair User • Herak Hostel)'),
          onPressed: () async {
            await store.login(identifier: 'aman.22je0123@iitism.ac.in', password: 'password');
            if (mounted) Navigator.pop(context);
          },
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Text('👩‍🦯', style: TextStyle(fontSize: 18)),
          label: const Text('Login as Priya (Visual Assist Student)'),
          onPressed: () async {
            await store.login(identifier: 'priya.22je0456@iitism.ac.in', password: 'password');
            if (mounted) Navigator.pop(context);
          },
        ),
      ],
    );
  }

  // ---------------- 3. ADMIN PORTAL ----------------
  Widget _buildAdminTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFECACA)),
          ),
          child: const Row(
            children: [
              Icon(Icons.shield_outlined, color: Color(0xFFDC2626), size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'IIT (ISM) Campus Infrastructure & Estate Administration Portal',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF991B1B)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        TextField(
          controller: _adminEmailCtrl,
          decoration: InputDecoration(
            labelText: 'Campus Admin Email',
            hintText: 'admin@iitism.ac.in',
            prefixIcon: const Icon(Icons.admin_panel_settings_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _adminPinCtrl,
          decoration: InputDecoration(
            labelText: 'Admin Security PIN / Password',
            hintText: 'Default PIN: 1926 or admin123',
            prefixIcon: const Icon(Icons.pin_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 20),

        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.verified_user_rounded),
          label: const Text('Access Admin Controls (PIN: 1926)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          onPressed: () async {
            final ok = await store.adminLogin(
              email: _adminEmailCtrl.text.trim(),
              pin: _adminPinCtrl.text.trim(),
            );

            if (mounted) {
              if (ok) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🛡️ Welcome, Campus Administrator! Admin controls activated.'),
                    backgroundColor: Color(0xFFDC2626),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid Admin PIN! Use "1926" or "admin123"')),
                );
              }
            }
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Admin Capabilities:\n• Toggle lift maintenance status (e.g., Herak Hostel Lifts)\n• Publish official campus accessibility advisories\n• Verify peer-submitted accessibility ratings',
          style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.5),
        ),
      ],
    );
  }
}
