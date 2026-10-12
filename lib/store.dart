// ============================================================
// store.dart — State, Offline Storage, Auth, GPS & Dwell Detection
// ============================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'data.dart';
import 'services/firebase_service.dart';

class AppStore extends ChangeNotifier {
  List<Place> places = [];
  AppUser? currentUser; // Logged-in user (Student or Admin)
  Position? myPos;

  // Dynamic Theme mode (Dark & Light support)
  ThemeMode themeMode = ThemeMode.dark;
  bool get isDarkMode => themeMode == ThemeMode.dark;

  // Backend sync config (Local Server, Vercel Serverless & Firebase Cloud)
  bool isSyncing = false;
  bool isOnline = true;
  Timer? _syncTimer;
  bool isFirstTimeUser = false;
  String? customBackendUrl;

  // Auto-detect server URL depending on platform or custom Vercel deployment
  String get serverBaseUrl {
    if (customBackendUrl != null && customBackendUrl!.trim().isNotEmpty) {
      return customBackendUrl!.trim();
    }
    if (kIsWeb) return 'http://127.0.0.1:8080';
    try {
      if (Platform.isAndroid) {
        // Android Emulator uses 10.0.2.2 to reach host machine localhost
        return 'http://10.0.2.2:8080';
      }
    } catch (_) {}
    // LAN / Desktop / Default
    return 'http://127.0.0.1:8080';
  }

  // Dwell detection internals
  String? _dwellId;
  DateTime? _dwellStart;
  final _prompted = <String>{};
  Timer? _timer;

  void Function(Place)? onDwell;

  bool get isLoggedIn => currentUser != null;
  bool get isAdmin => currentUser?.role == UserRole.admin;

  // Backward compatibility alias
  AppUser? get profile => currentUser;

  // ---------------- SAVE / LOAD & SYNC ----------------

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final hasOpenedBefore = sp.getBool('hasOpenedBefore') ?? false;
    isFirstTimeUser = !hasOpenedBefore;

    final isDark = sp.getBool('isDarkMode') ?? true;
    themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    customBackendUrl = sp.getString('customBackendUrl');

    final userJson = sp.getString('currentUser');
    if (userJson != null) {
      currentUser = AppUser.fromJson(jsonDecode(userJson));
    } else {
      // Default initial demo user: Aman (Student, Wheelchair user)
      currentUser = const AppUser(
        id: 'u1',
        name: 'Aman Sharma',
        rollNo: '22JE0123',
        email: 'aman.22je0123@iitism.ac.in',
        role: UserRole.student,
        avatarEmoji: '🧑‍🦽',
        needsPreference: 'Wheelchair User',
      );
    }

    final dj = sp.getString('places');
    places = dj != null
        ? (jsonDecode(dj) as List).map((e) => Place.fromJson(e)).toList()
        : seedPlaces();

    // Start background sync with backend server & Firebase Cloud
    syncWithBackend();
    _startSyncTimer();
  }

  Future<void> setCustomBackendUrl(String? url) async {
    customBackendUrl = url?.trim();
    final sp = await SharedPreferences.getInstance();
    if (customBackendUrl != null && customBackendUrl!.isNotEmpty) {
      await sp.setString('customBackendUrl', customBackendUrl!);
    } else {
      await sp.remove('customBackendUrl');
    }
    notifyListeners();
    syncWithBackend();
  }

  Future<void> toggleTheme() async {
    themeMode = (themeMode == ThemeMode.dark) ? ThemeMode.light : ThemeMode.dark;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('isDarkMode', themeMode == ThemeMode.dark);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('isDarkMode', themeMode == ThemeMode.dark);
    notifyListeners();
  }

  void _startSyncTimer() {
    _syncTimer?.cancel();
    // Poll backend every 12 seconds so updates on device A reflect on device B
    _syncTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      pullUpdatesFromBackend();
    });
  }

  Future<void> completeOnboarding() async {
    isFirstTimeUser = false;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('hasOpenedBefore', true);
    notifyListeners();
  }

  Future<void> save() async {
    final sp = await SharedPreferences.getInstance();
    if (currentUser != null) {
      sp.setString('currentUser', jsonEncode(currentUser!.toJson()));
    } else {
      sp.remove('currentUser');
    }
    sp.setString('places', jsonEncode(places.map((p) => p.toJson()).toList()));

    // Also push to backend server and Firebase Cloud asynchronously
    syncWithBackend();
  }

  // Two-way synchronization with backend server & Firebase
  Future<void> syncWithBackend() async {
    // In automated widget testing, avoid outgoing HTTP calls
    if (kDebugMode && Platform.environment.containsKey('FLUTTER_TEST')) return;
    if (isSyncing) return;
    isSyncing = true;
    try {
      // 1. Sync with Local Server
      final uri = Uri.parse('$serverBaseUrl/api/places/sync');
      final res = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: jsonEncode({
              'places': places.map((p) => p.toJson()).toList(),
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['places'] is List) {
          final serverPlaces = (data['places'] as List)
              .map((e) => Place.fromJson(e))
              .toList();
          if (serverPlaces.isNotEmpty) {
            places = serverPlaces;
            isOnline = true;
            notifyListeners();
          }
        }
      }

      // 2. Sync to Firebase Cloud
      await FirebaseService.instance.syncPlacesToFirebase(places);
    } catch (e) {
      // Try Firebase if local server unreachable
      try {
        await FirebaseService.instance.syncPlacesToFirebase(places);
      } catch (_) {}
      isOnline = false;
    } finally {
      isSyncing = false;
    }
  }

  // Poll updates from backend & Firebase
  Future<void> pullUpdatesFromBackend() async {
    if (kDebugMode && Platform.environment.containsKey('FLUTTER_TEST')) return;
    try {
      final uri = Uri.parse('$serverBaseUrl/api/places');
      final res = await http.get(uri).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['places'] is List) {
          final serverList = (data['places'] as List)
              .map((e) => Place.fromJson(e))
              .toList();
          if (serverList.isNotEmpty) {
            places = serverList;
            isOnline = true;
            final sp = await SharedPreferences.getInstance();
            sp.setString('places', jsonEncode(places.map((p) => p.toJson()).toList()));
            notifyListeners();
            return;
          }
        }
      }
    } catch (_) {
      isOnline = false;
      // Fallback: poll from Firebase Cloud
      try {
        final fbPlaces = await FirebaseService.instance.fetchPlacesFromFirebase();
        if (fbPlaces != null && fbPlaces.isNotEmpty) {
          places = fbPlaces;
          notifyListeners();
        }
      } catch (_) {}
    }
  }

  // ---------------- AUTHENTICATION (3-TIER) ----------------

  // 1. Sign Up (New User)
  Future<void> signup({
    required String name,
    required String rollNo,
    required String email,
    required String password,
    String persona = 'General',
    String emoji = '🧑‍🎓',
  }) async {
    currentUser = AppUser(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      rollNo: rollNo,
      email: email,
      role: UserRole.student,
      avatarEmoji: emoji,
      needsPreference: persona,
    );
    await save();
    notifyListeners();
  }

  // 2. Already User Login
  Future<bool> login({required String identifier, required String password}) async {
    // Demo account matching or creating session
    if (identifier.toLowerCase().contains('admin')) {
      return adminLogin(email: identifier, pin: password);
    }

    currentUser = AppUser(
      id: 'u_${identifier.hashCode}',
      name: identifier.split('@').first,
      rollNo: identifier.contains('@') ? identifier.split('@').first : identifier,
      email: identifier.contains('@') ? identifier : '$identifier@iitism.ac.in',
      role: UserRole.student,
      avatarEmoji: '🧑‍🎓',
      needsPreference: 'Student',
    );
    await save();
    notifyListeners();
    return true;
  }

  // 3. Admin Login (IIT ISM Campus Administrator)
  Future<bool> adminLogin({required String email, required String pin}) async {
    // Admin password or founding year of ISM 1926
    if (pin == '1926' || pin == 'admin123' || pin.toLowerCase() == 'admin') {
      currentUser = const AppUser(
        id: 'admin_1',
        name: 'IIT (ISM) Campus Admin',
        rollNo: 'FACULTY-ADMIN',
        email: 'admin@iitism.ac.in',
        role: UserRole.admin,
        avatarEmoji: '🛡️',
        needsPreference: 'Campus Administration',
      );
      await save();
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    currentUser = null;
    save();
    notifyListeners();
  }

  void setProfile(AppUser p) {
    currentUser = p;
    save();
    notifyListeners();
  }

  // ---------------- ADMIN ACTIONS ----------------

  void toggleLiftStatus(String placeId, bool isOperational) {
    final idx = places.indexWhere((p) => p.id == placeId);
    if (idx != -1) {
      places[idx].isLiftOperational = isOperational;
      save();
      notifyListeners();
    }
  }

  void setAdminNotice(String placeId, String? notice) {
    final idx = places.indexWhere((p) => p.id == placeId);
    if (idx != -1) {
      places[idx].adminNotice = notice;
      save();
      notifyListeners();
    }
  }

  // ---------------- DATA ACTIONS ----------------

  void addReview(Place p, Review r) {
    p.reviews.add(r);
    save();
    notifyListeners();
  }

  void upvoteReview(Place p, Review r) {
    r.upvotes += 1;
    save();
    notifyListeners();
  }

  void addPlace(Place p) {
    places.add(p);
    save();
    notifyListeners();
  }

  // ---------------- 📍 LOCATION & DWELL DETECTION ----------------

  Future<bool> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return perm == LocationPermission.always || perm == LocationPermission.whileInUse;
  }

  Future<void> startWatch() async {
    if (!await ensurePermission()) return;
    _tick();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _tick());
  }

  Future<void> _tick() async {
    try {
      myPos = await Geolocator.getCurrentPosition();
      _checkDwell();
      notifyListeners();
    } catch (_) {}
  }

  double? distanceTo(Place p) => myPos == null
      ? null
      : Geolocator.distanceBetween(myPos!.latitude, myPos!.longitude, p.lat, p.lng);

  void _checkDwell() {
    if (myPos == null) return;
    Place? near;
    double best = 150;
    for (final p in places) {
      final d = distanceTo(p)!;
      if (d < best) {
        best = d;
        near = p;
      }
    }
    if (near == null) {
      _dwellId = null;
      return;
    }
    if (_dwellId != near.id) {
      _dwellId = near.id;
      _dwellStart = DateTime.now();
      return;
    }
    if (!_prompted.contains(near.id) &&
        DateTime.now().difference(_dwellStart!) >= const Duration(minutes: 2)) {
      _prompted.add(near.id);
      onDwell?.call(near);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _syncTimer?.cancel();
    super.dispose();
  }
}

final store = AppStore();
