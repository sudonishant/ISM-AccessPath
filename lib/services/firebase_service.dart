// ============================================================
// firebase_service.dart — Firebase Cloud Backend Integration
// Real-time synchronization for places, reviews & campus estate notices
// ============================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models.dart';

class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  // Firebase Realtime Database & Firestore REST endpoints
  String _projectId = 'accesspath-iitism';
  String _databaseUrl = 'https://accesspath-iitism-default-rtdb.firebaseio.com';
  bool isConnected = false;
  String lastSyncMessage = 'Firebase Ready';

  String get projectId => _projectId;
  String get databaseUrl => _databaseUrl;

  void configure({required String projectId, String? databaseUrl}) {
    _projectId = projectId;
    if (databaseUrl != null) {
      _databaseUrl = databaseUrl;
    } else {
      _databaseUrl = 'https://$projectId-default-rtdb.firebaseio.com';
    }
  }

  // 1. Sync entire places collection to Firebase Cloud
  Future<bool> syncPlacesToFirebase(List<Place> places) async {
    try {
      final url = Uri.parse('$_databaseUrl/places.json');
      final body = jsonEncode(places.map((p) => p.toJson()).toList());

      final res = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        isConnected = true;
        lastSyncMessage = 'Synced ${places.length} places to Firebase';
        if (kDebugMode) print('[Firebase] Cloud sync success: ${res.statusCode}');
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('[Firebase] Cloud sync exception: $e');
      lastSyncMessage = 'Firebase offline / local cache active';
    }
    return false;
  }

  // 2. Fetch latest places collection from Firebase Cloud
  Future<List<Place>?> fetchPlacesFromFirebase() async {
    try {
      final url = Uri.parse('$_databaseUrl/places.json');
      final res = await http.get(url).timeout(const Duration(seconds: 6));

      if (res.statusCode == 200 && res.body != 'null') {
        final decoded = jsonDecode(res.body);
        if (decoded is List) {
          isConnected = true;
          lastSyncMessage = 'Loaded from Firebase Cloud';
          return decoded.map((e) => Place.fromJson(e)).toList();
        } else if (decoded is Map) {
          isConnected = true;
          return decoded.values.map((e) => Place.fromJson(e)).toList();
        }
      }
    } catch (e) {
      if (kDebugMode) print('[Firebase] Fetch exception: $e');
    }
    return null;
  }

  // 3. Push a single new review to Firebase Cloud
  Future<bool> pushReviewToFirebase(String placeId, Review review) async {
    try {
      final url = Uri.parse('$_databaseUrl/reviews/$placeId.json');
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(review.toJson()),
      ).timeout(const Duration(seconds: 6));

      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  // 4. Update building lift status & notices in Firebase
  Future<bool> updateBuildingStatusInFirebase({
    required String placeId,
    required bool isLiftOperational,
    String? adminNotice,
  }) async {
    try {
      final url = Uri.parse('$_databaseUrl/status/$placeId.json');
      final res = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'isLiftOperational': isLiftOperational,
          'adminNotice': adminNotice,
          'updatedAt': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 6));

      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}
