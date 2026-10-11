// ============================================================
// auth_page.dart — 3-Tier Authentication (Sign Up, Formatted Login, Admin)
// Styled with Cyberpunk Dark Theme matching AI Assistant
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../store.dart';
import 'admin_report_page.dart';

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
  bool _obscureSignupPass = true;

  // Login Controllers
  final _loginIdCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();
  bool _obscureLoginPass = true;
  String? _loginIdError;
  String? _loginPassError;

  // Admin Portal Controllers
  final _adminEmailCtrl = TextEditingController(text: 'admin@iitism.ac.in');
  final _adminPinCtrl = TextEditingController(text: '1926');
  bool _obscureAdminPin = true;

  final List<(String, String)> _personas = [
    ('🧑‍🦽', 'Wheelchair User'),
    ('👩‍🦯', 'Visual Assistance'),
    ('🧏', 'Hearing Assistance'),
    ('🦯', 'Mobility / Crutches'),
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

  // Validate format of Roll No or Email
  bool _validateLoginFormat() {
    setState(() {
      _loginIdError = null;
      _loginPassError = null;
    });

    final id = _loginIdCtrl.text.trim();
    final pass = _loginPassCtrl.text;

    if (id.isEmpty) {
      setState(() => _loginIdError = 'Please enter your Roll No or Email');
      return false;
    }

    // Check if Roll No (e.g., 22JE0123) or Email (e.g. name@iitism.ac.in)
    final rollRegex = RegExp(r'^[0-9]{2}[A-Za-z]{2}[0-9]{4}$');
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!rollRegex.hasMatch(id) && !emailRegex.hasMatch(id)) {
      setState(() => _loginIdError = 'Format invalid. Use Roll No (e.g. 22JE0123) or Email');
      return false;
    }

    if (pass.isEmpty) {
      setState(() => _loginPassError = 'Password is required');
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/logo/accesspath_logo.png',
                width: 28,
                height: 28,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.accessible_forward, color: Color(0xFF00F0FF)),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'AccessPath Account',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00F0FF),
          indicatorWeight: 3,
          labelColor: const Color(0xFF00F0FF),
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.login_rounded), text: 'Log In'),
            Tab(icon: Icon(Icons.person_add_alt_1_rounded), text: 'New User'),
            Tab(icon: Icon(Icons.admin_panel_settings_rounded), text: 'Admin Portal'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLoginTab(),
          _buildNewUserTab(),
          _buildAdminTab(),
        ],
      ),
    );
  }

  // ---------------- 1. FORMATTED LOG IN ----------------
  Widget _buildLoginTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Header Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF131F37),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: const Row(
            children: [
              Icon(Icons.lock_person_rounded, color: Color(0xFF00F0FF), size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to AccessPath',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Enter your Admission Roll Number (e.g. 22JE0123) or IIT ISM Email to sign in.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Roll Number / Email Input (with Uppercase formatter)
        const Text(
          'IIT (ISM) Roll Number or Email ID *',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _loginIdCtrl,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          inputFormatters: [
            // Auto uppercase
            TextInputFormatter.withFunction((oldValue, newValue) {
              return newValue.copyWith(text: newValue.text.toUpperCase());
            }),
          ],
          decoration: InputDecoration(
            hintText: 'e.g. 22JE0123 or student@iitism.ac.in',
            hintStyle: const TextStyle(color: Color(0xFF475569)),
            prefixIcon: const Icon(Icons.badge_outlined, color: Color(0xFF00F0FF)),
            filled: true,
            fillColor: const Color(0xFF131F37),
            errorText: _loginIdError,
            errorStyle: const TextStyle(color: Color(0xFFF87171)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF1E293B)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF00F0FF), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Password Input with show/hide
        const Text(
          'Password *',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _loginPassCtrl,
          obscureText: _obscureLoginPass,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter your password',
            hintStyle: const TextStyle(color: Color(0xFF475569)),
            prefixIcon: const Icon(Icons.key_rounded, color: Color(0xFF00F0FF)),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureLoginPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF64748B),
              ),
              onPressed: () => setState(() => _obscureLoginPass = !_obscureLoginPass),
            ),
            filled: true,
            fillColor: const Color(0xFF131F37),
            errorText: _loginPassError,
            errorStyle: const TextStyle(color: Color(0xFFF87171)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF1E293B)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF00F0FF), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Sign In Button
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF00F0FF),
            foregroundColor: const Color(0xFF0B132B),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.arrow_forward_rounded, size: 20),
          label: const Text('Sign In to AccessPath', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          onPressed: () async {
            if (!_validateLoginFormat()) return;

            final id = _loginIdCtrl.text.trim();
            final pass = _loginPassCtrl.text;
            await store.login(identifier: id, password: pass);

            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Welcome back, ${store.currentUser!.name}! Session active.'),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            }
          },
        ),
        const SizedBox(height: 28),

        // Quick Input Format Helpers
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quick Format Helper (Click to autofill format):',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    backgroundColor: const Color(0xFF1E293B),
                    avatar: const Text('🧑‍🦽', style: TextStyle(fontSize: 14)),
                    label: const Text('22JE0123 (Aman - Herakles)', style: TextStyle(color: Color(0xFF00F0FF), fontSize: 11)),
                    onPressed: () {
                      _loginIdCtrl.text = '22JE0123';
                      _loginPassCtrl.text = 'pass123';
                      setState(() {
                        _loginIdError = null;
                        _loginPassError = null;
                      });
                    },
                  ),
                  ActionChip(
                    backgroundColor: const Color(0xFF1E293B),
                    avatar: const Text('👩‍🦯', style: TextStyle(fontSize: 14)),
                    label: const Text('22JE0456 (Priya - Visual)', style: TextStyle(color: Color(0xFF00F0FF), fontSize: 11)),
                    onPressed: () {
                      _loginIdCtrl.text = '22JE0456';
                      _loginPassCtrl.text = 'pass123';
                      setState(() {
                        _loginIdError = null;
                        _loginPassError = null;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- 2. NEW USER (SIGN UP) ----------------
  Widget _buildNewUserTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Join IIT (ISM) Access Network',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        const Text(
          'Create your verified campus profile to contribute accessibility reviews, ratings, and photos.',
          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 16),

        // Persona Chooser
        const Text(
          'Select Accessibility Persona / Special Needs:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF00F0FF)),
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
                  selectedColor: const Color(0xFF00F0FF),
                  backgroundColor: const Color(0xFF1E293B),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFF0B132B) : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12,
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
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Full Name *',
            hintText: 'e.g. Aman Sharma',
            labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
            hintStyle: const TextStyle(color: Color(0xFF475569)),
            prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF00F0FF)),
            filled: true,
            fillColor: const Color(0xFF131F37),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1E293B))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF00F0FF))),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _signupRollCtrl,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(color: Colors.white),
          inputFormatters: [
            TextInputFormatter.withFunction((oldValue, newValue) {
              return newValue.copyWith(text: newValue.text.toUpperCase());
            }),
          ],
          decoration: InputDecoration(
            labelText: 'Admission / Roll Number *',
            hintText: 'e.g. 22JE0123',
            labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
            hintStyle: const TextStyle(color: Color(0xFF475569)),
            prefixIcon: const Icon(Icons.school_outlined, color: Color(0xFF00F0FF)),
            filled: true,
            fillColor: const Color(0xFF131F37),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1E293B))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF00F0FF))),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _signupEmailCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'IIT ISM Email ID',
            hintText: 'student@iitism.ac.in',
            labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
            hintStyle: const TextStyle(color: Color(0xFF475569)),
            prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF00F0FF)),
            filled: true,
            fillColor: const Color(0xFF131F37),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1E293B))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF00F0FF))),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _signupPassCtrl,
          obscureText: _obscureSignupPass,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Password *',
            labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF00F0FF)),
            suffixIcon: IconButton(
              icon: Icon(_obscureSignupPass ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF64748B)),
              onPressed: () => setState(() => _obscureSignupPass = !_obscureSignupPass),
            ),
            filled: true,
            fillColor: const Color(0xFF131F37),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1E293B))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF00F0FF))),
          ),
        ),
        const SizedBox(height: 20),

        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: const Color(0xFF0B132B),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: () async {
            if (_signupNameCtrl.text.trim().isEmpty || _signupRollCtrl.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill your name and roll number! ✍️')),
              );
              return;
            }

            await store.signup(
              name: _signupNameCtrl.text.trim(),
              rollNo: _signupRollCtrl.text.trim(),
              email: _signupEmailCtrl.text.trim().isEmpty ? '${_signupRollCtrl.text.trim().toLowerCase()}@iitism.ac.in' : _signupEmailCtrl.text.trim(),
              password: _signupPassCtrl.text.trim(),
              persona: _selectedPersona,
              emoji: _selectedEmoji,
            );

            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Welcome, ${store.currentUser!.name}! Account created.'),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            }
          },
          child: const Text('Create New Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEF4444)),
          ),
          child: const Row(
            children: [
              Icon(Icons.shield_outlined, color: Color(0xFFEF4444), size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'IIT (ISM) Campus Infrastructure & Estate Administration',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        TextField(
          controller: _adminEmailCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Campus Admin Email',
            hintText: 'admin@iitism.ac.in',
            labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
            prefixIcon: const Icon(Icons.admin_panel_settings_outlined, color: Color(0xFFEF4444)),
            filled: true,
            fillColor: const Color(0xFF131F37),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1E293B))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFEF4444))),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _adminPinCtrl,
          obscureText: _obscureAdminPin,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Admin Security PIN / Password',
            hintText: 'Default PIN: 1926 or admin123',
            labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
            prefixIcon: const Icon(Icons.pin_outlined, color: Color(0xFFEF4444)),
            suffixIcon: IconButton(
              icon: Icon(_obscureAdminPin ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF64748B)),
              onPressed: () => setState(() => _obscureAdminPin = !_obscureAdminPin),
            ),
            filled: true,
            fillColor: const Color(0xFF131F37),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1E293B))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFEF4444))),
          ),
        ),
        const SizedBox(height: 20),

        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminReportPage()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🛡️ Welcome, Campus Administrator! Admin controls & Audit report activated.'),
                    backgroundColor: Color(0xFFEF4444),
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
        const SizedBox(height: 16),

        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF00F0FF),
            side: const BorderSide(color: Color(0xFF00F0FF)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          icon: const Icon(Icons.assessment_rounded),
          label: const Text('View Campus Audit Reports Directly', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminReportPage()),
            );
          },
        ),
      ],
    );
  }
}
