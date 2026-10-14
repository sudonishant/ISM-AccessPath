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

  // In-app targeted notifications
  List<AppNotification> notifications = [];
  int get unreadNotificationsCount => notifications.where((n) => !n.isRead).length;

  // Active Safety & Animal Hazard Beacons (Real-time OpenCV Vision Detection)
  List<SafetyHazardBeacon> activeHazards = [];

  // Dynamic Theme mode (follows system device theme automatically)
  ThemeMode themeMode = ThemeMode.system;
  bool get isDarkMode => themeMode == ThemeMode.dark;

  // Backend sync config (Local Server, Vercel Serverless & Firebase Cloud)
  bool isSyncing = false;
  bool isOnline = true;
  Timer? _syncTimer;
  bool isFirstTimeUser = false;
  String? customBackendUrl;

  // Auto-detect server URL: defaults to production Vercel cloud server
  String get serverBaseUrl {
    if (customBackendUrl != null && customBackendUrl!.trim().isNotEmpty) {
      return customBackendUrl!.trim();
    }
    // Production Cloud Server deployed on Vercel
    return 'https://ism-access-path.vercel.app';
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

    // Follow device system theme automatically
    themeMode = ThemeMode.system;
    customBackendUrl = sp.getString('customBackendUrl');

    final userJson = sp.getString('currentUser');
    if (userJson != null) {
      currentUser = AppUser.fromJson(jsonDecode(userJson));
      await fetchNotifications();
    } else {
      currentUser = null;
    }

    final dj = sp.getString('places');
    places = dj != null
        ? (jsonDecode(dj) as List).map((e) => Place.fromJson(e)).toList()
        : seedPlaces();

    final hzJson = sp.getString('active_campus_hazards');
    activeHazards = hzJson != null
        ? (jsonDecode(hzJson) as List).map((e) => SafetyHazardBeacon.fromJson(e)).toList()
        : _seedHazards();
    fetchHazards();

    // Start background sync with backend server & Firebase Cloud
    syncWithBackend();
    _startSyncTimer();
  }

  List<SafetyHazardBeacon> _seedHazards() => [
        SafetyHazardBeacon(
          id: 'hz_seed_1',
          type: 'animal_dog',
          title: 'Stray Dog Pack spotted',
          description: '3-4 aggressive dogs resting near Amber Hostel ramp walkway. Acoustic repeller active.',
          lat: 23.8129,
          lng: 86.4402,
          severity: 'high',
          threatClass: 'dog',
          reportedBy: 'Amber Hall Warden',
          timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
        SafetyHazardBeacon(
          id: 'hz_seed_2',
          type: 'animal_monkey',
          title: 'Simian / Monkey troop near tree line',
          description: 'Monkeys reported grabbing snack packets along Student Activity Centre (SAC) pathway.',
          lat: 23.8160,
          lng: 86.4428,
          severity: 'medium',
          threatClass: 'monkey',
          reportedBy: 'SAC Security Post',
          timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        ),
      ];

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
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    notifyListeners();
  }

  void _startSyncTimer() {
    _syncTimer?.cancel();
    // Poll backend every 6 seconds so updates on device A reflect on device B in real-time
    _syncTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      pullUpdatesFromBackend();
      fetchHazards();
      if (currentUser != null) {
        fetchNotifications();
      }
    });
  }

  // Fetch active safety hazards from backend
  Future<void> fetchHazards() async {
    if (kDebugMode && Platform.environment.containsKey('FLUTTER_TEST')) return;
    try {
      final uri = Uri.parse('$serverBaseUrl/api/hazards');
      final res = await http.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['hazards'] is List) {
          final serverHazards = (data['hazards'] as List)
              .map((e) => SafetyHazardBeacon.fromJson(e))
              .toList();
          if (serverHazards.isNotEmpty) {
            activeHazards = serverHazards;
            final sp = await SharedPreferences.getInstance();
            sp.setString('active_campus_hazards', jsonEncode(activeHazards.map((h) => h.toJson()).toList()));
            notifyListeners();
          }
        }
      }
    } catch (_) {}
  }

  // Broadcast safety hazard beacon (pins to map, triggers sound/light alert, and syncs to community)
  Future<void> broadcastHazard(SafetyHazardBeacon beacon) async {
    activeHazards.removeWhere((h) => h.id == beacon.id);
    activeHazards.insert(0, beacon);
    save();
    notifyListeners();

    // Add local notification
    notifications.insert(0, AppNotification(
      id: 'local_hazard_${DateTime.now().millisecondsSinceEpoch}',
      targetUser: currentUser?.name ?? 'all',
      fromUser: beacon.reportedBy,
      title: '${beacon.icon} Campus Hazard Alert: ${beacon.title}',
      message: '${beacon.description} Location pinned on campus map.',
      placeId: beacon.id,
      time: DateTime.now(),
    ));
    notifyListeners();

    // Instant multi-device push to backend server
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      http.post(
        Uri.parse('$serverBaseUrl/api/hazards'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode(beacon.toJson()),
      ).timeout(const Duration(seconds: 4)).catchError((_) => http.Response('', 500));
    }
  }

  // Fetch targeted notifications for this logged-in user
  Future<void> fetchNotifications() async {
    if (currentUser == null) return;
    if (kDebugMode && Platform.environment.containsKey('FLUTTER_TEST')) return;
    try {
      final userQuery = Uri.encodeComponent(currentUser!.name);
      final uri = Uri.parse('$serverBaseUrl/api/notifications?user=$userQuery');
      final res = await http.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['notifications'] is List) {
          notifications = (data['notifications'] as List)
              .map((e) => AppNotification.fromJson(e))
              .toList();
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  // Mark in-app notifications as read
  Future<void> markNotificationsRead() async {
    for (final n in notifications) {
      n.isRead = true;
    }
    notifyListeners();
    if (currentUser == null) return;
    try {
      final uri = Uri.parse('$serverBaseUrl/api/notifications/read');
      await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          'user': currentUser!.name,
          'id': 'all',
        }),
      ).timeout(const Duration(seconds: 4));
    } catch (_) {}
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
      final uJson = jsonEncode(currentUser!.toJson());
      sp.setString('currentUser', uJson);
      sp.setString('user_profile_${currentUser!.id}', uJson);
      sp.setString('user_profile_${currentUser!.rollNo.toLowerCase()}', uJson);
      sp.setString('user_profile_${currentUser!.email.toLowerCase()}', uJson);
    } else {
      sp.remove('currentUser');
    }
    sp.setString('places', jsonEncode(places.map((p) => p.toJson()).toList()));
    sp.setString('active_campus_hazards', jsonEncode(activeHazards.map((h) => h.toJson()).toList()));

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
    fetchNotifications();
    notifyListeners();
  }

  // 2. Already User Login
  Future<bool> login({required String identifier, required String password}) async {
    if (identifier.toLowerCase().contains('admin')) {
      return adminLogin(email: identifier, pin: password);
    }

    final sp = await SharedPreferences.getInstance();
    final cleanId = identifier.trim().toLowerCase();
    final savedProfile = sp.getString('user_profile_$cleanId');
    if (savedProfile != null) {
      try {
        currentUser = AppUser.fromJson(jsonDecode(savedProfile));
        await save();
        fetchNotifications();
        notifyListeners();
        return true;
      } catch (_) {}
    }

    final displayName = identifier.contains('@') ? identifier.split('@').first : identifier;
    currentUser = AppUser(
      id: 'u_${cleanId.hashCode.abs()}',
      name: displayName,
      rollNo: identifier.contains('@') ? identifier.split('@').first : identifier,
      email: identifier.contains('@') ? identifier : '$identifier@iitism.ac.in',
      role: UserRole.student,
      avatarEmoji: '🧑‍🎓',
      needsPreference: 'Student',
    );
    await save();
    fetchNotifications();
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
      fetchNotifications();
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

  // ---------------- DATA ACTIONS (CROSS-DEVICE SYNC) ----------------

  void addReview(Place p, Review r) {
    p.reviews.add(r);
    save();
    notifyListeners();

    // Instant push to backend for real-time reflection across devices
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      http.post(
        Uri.parse('$serverBaseUrl/api/reviews'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          'placeId': p.id,
          'review': r.toJson(),
        }),
      ).timeout(const Duration(seconds: 4)).catchError((_) => http.Response('', 500));
    }
  }

  void upvoteReview(Place p, Review r) {
    r.upvotes += 1;
    save();
    notifyListeners();

    // Send targeted like notification specifically to review author
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      http.post(
        Uri.parse('$serverBaseUrl/api/reviews/like'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          'placeId': p.id,
          'reviewUser': r.user,
          'likedBy': currentUser?.name ?? 'A fellow student',
          'placeName': p.name,
        }),
      ).timeout(const Duration(seconds: 4)).catchError((_) => http.Response('', 500));
    }
  }

  void addPlace(Place p) {
    places.add(p);
    save();
    notifyListeners();

    // Instant push to backend for real-time reflection across devices
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      http.post(
        Uri.parse('$serverBaseUrl/api/places'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode(p.toJson()),
      ).timeout(const Duration(seconds: 4)).catchError((_) => http.Response('', 500));
    }
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
