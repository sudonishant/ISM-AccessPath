// ============================================================
// models.dart — IIT (ISM) Dhanbad Accessibility Data Models
// ============================================================

import 'package:flutter/material.dart';

// ------------------------------------------------------------
// 5 CORE ACCESSIBILITY CATEGORIES
// ------------------------------------------------------------
const kCategories = [
  ('🛗', 'Step-free Access'), // Ramp / zero-step entrance
  ('⬆️', 'Lift'),             // Elevator availability & functioning
  ('🚻', 'Washroom'),         // Wheelchair & divyang accessible toilets
  ('💺', 'Seating'),          // Rest areas, benches, priority seating
  ('🧭', 'Wayfinding'),       // Braille, tactile paving, clear signage
];

// Campus Place Categories
const kPlaceTypes = [
  'Hostel',
  'Academic',
  'Library',
  'Auditorium',
  'Health',
  'Canteen',
  'Recreation',
  'Charging',
];

// ------------------------------------------------------------
// FLOOR INFO — Detailed Floor Architecture (Herak Hostel etc.)
// ------------------------------------------------------------
class FloorInfo {
  final int floorNumber; // 0 = Ground, 1 = 1st, ..., 5 = 5th
  final String name; // e.g. "Ground Floor", "1st Floor"
  final int totalWashrooms; // e.g. 10
  final int accessibleWashrooms; // e.g. 2
  final int liftsCount; // e.g. 2
  final bool hasRamp;
  final List<String> facilities;

  const FloorInfo({
    required this.floorNumber,
    required this.name,
    this.totalWashrooms = 10,
    this.accessibleWashrooms = 2,
    this.liftsCount = 2,
    this.hasRamp = false,
    this.facilities = const [],
  });

  Map<String, dynamic> toJson() => {
        'fn': floorNumber,
        'nm': name,
        'tw': totalWashrooms,
        'aw': accessibleWashrooms,
        'lc': liftsCount,
        'hr': hasRamp,
        'fc': facilities,
      };

  factory FloorInfo.fromJson(Map<String, dynamic> j) => FloorInfo(
        floorNumber: j['fn'] ?? 0,
        name: j['nm'] ?? 'Floor',
        totalWashrooms: j['tw'] ?? 10,
        accessibleWashrooms: j['aw'] ?? 2,
        liftsCount: j['lc'] ?? 2,
        hasRamp: j['hr'] ?? false,
        facilities: List<String>.from(j['fc'] ?? []),
      );
}

// ------------------------------------------------------------
// USER & ROLES (New User, Already User, Admin)
// ------------------------------------------------------------
enum UserRole { student, admin }

class AppUser {
  final String id;
  final String name;
  final String rollNo;
  final String email;
  final UserRole role;
  final String avatarEmoji;
  final String needsPreference; // e.g. "Wheelchair User", "Visual Assistance", "None"

  const AppUser({
    required this.id,
    required this.name,
    required this.rollNo,
    required this.email,
    this.role = UserRole.student,
    this.avatarEmoji = '🧑‍🎓',
    this.needsPreference = 'General',
  });

  bool get isAdmin => role == UserRole.admin;

  Map<String, dynamic> toJson() => {
        'id': id,
        'n': name,
        'r': rollNo,
        'e': email,
        'ro': role.name,
        'av': avatarEmoji,
        'np': needsPreference,
      };

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: j['id'] ?? '',
        name: j['n'] ?? '',
        rollNo: j['r'] ?? '',
        email: j['e'] ?? '',
        role: j['ro'] == 'admin' ? UserRole.admin : UserRole.student,
        avatarEmoji: j['av'] ?? '🧑‍🎓',
        needsPreference: j['np'] ?? 'General',
      );
}

// ------------------------------------------------------------
// REVIEW
// ------------------------------------------------------------
class Review {
  // 5 categories nullable (1-5, or null if skipped by user)
  final List<int?> scores;
  final String comment;
  final String user;
  final String? userRole; // e.g. "Admin", "Student"
  final String? photoPath;
  final String? targetTag; // Specific single feature review (e.g. '🛗 Ground Entrance Ramp')
  final int? targetFloor; // Specific floor reviewed (0 = Ground, 1 = 1st, etc.)
  final String userCategory; // 'general' or 'disabled'
  final String? disabilityType; // e.g. 'Wheelchair / Mobility', 'Visual Impairment', 'Hearing Impairment', 'Elderly / Crutches', 'Other'
  int upvotes; // Community verified helpfulness count
  final DateTime time;

  Review({
    required this.scores,
    required this.comment,
    required this.user,
    this.userRole = 'Student',
    this.photoPath,
    this.targetTag,
    this.targetFloor,
    this.userCategory = 'general',
    this.disabilityType,
    this.upvotes = 0,
    DateTime? time,
  }) : time = time ?? DateTime.now();

  bool get isSpecialNeeds => userCategory == 'disabled';

  double get validAvg {
    final nonNullScores = scores.whereType<int>().toList();
    if (nonNullScores.isEmpty) return 0.0;
    return nonNullScores.reduce((a, b) => a + b) / nonNullScores.length;
  }

  double get overallScore => validAvg;
  DateTime get date => time;

  int? get stepFree => scores.isNotEmpty ? scores[0] : null;
  int? get lift => scores.length > 1 ? scores[1] : null;
  int? get washroom => scores.length > 2 ? scores[2] : null;
  int? get seating => scores.length > 3 ? scores[3] : null;
  int? get wayfinding => scores.length > 4 ? scores[4] : null;

  String get timeAgo {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  Map<String, dynamic> toJson() => {
        's': scores,
        'c': comment,
        'u': user,
        'ur': userRole,
        'p': photoPath,
        'tt': targetTag,
        'tf': targetFloor,
        'uc': userCategory,
        'dt': disabilityType,
        'up': upvotes,
        't': time.toIso8601String(),
      };

  factory Review.fromJson(Map<String, dynamic> j) => Review(
        scores: (j['s'] as List).map((e) => e == null ? null : (e as num).toInt()).toList(),
        comment: j['c'] ?? '',
        user: j['u'] ?? 'Student',
        userRole: j['ur'] ?? 'Student',
        photoPath: j['p'],
        targetTag: j['tt'],
        targetFloor: j['tf'],
        userCategory: j['uc'] ?? ((j['ur'] != null && j['ur'] != 'Student' && j['ur'] != 'Admin') ? 'disabled' : 'general'),
        disabilityType: j['dt'],
        upvotes: j['up'] ?? 0,
        time: DateTime.parse(j['t']),
      );
}

// ------------------------------------------------------------
// CAMPUS PLACE
// ------------------------------------------------------------
class Place {
  final String id, name, type;
  final double lat, lng;
  final bool isCustom;
  final List<Review> reviews;
  final List<FloorInfo> floors; // Detailed floor plans
  bool isLiftOperational;
  String? adminNotice;

  Place({
    required this.id,
    required this.name,
    required this.type,
    required this.lat,
    required this.lng,
    this.isCustom = false,
    List<Review>? reviews,
    List<FloorInfo>? floors,
    this.isLiftOperational = true,
    this.adminNotice,
  })  : reviews = reviews ?? [],
        floors = floors ?? [];

  List<Review> get generalReviews => reviews.where((r) => !r.isSpecialNeeds).toList();
  List<Review> get specialReviews => reviews.where((r) => r.isSpecialNeeds).toList();

  // Average for category i, ignoring reviews where facility was skipped (null)
  double avg(int i, {String filter = 'all'}) {
    final list = filter == 'general'
        ? generalReviews
        : (filter == 'disabled' ? specialReviews : reviews);
    final validScores = list
        .where((r) => i < r.scores.length && r.scores[i] != null)
        .map((r) => r.scores[i]!)
        .toList();

    if (validScores.isEmpty) return 0.0;
    return validScores.reduce((a, b) => a + b) / validScores.length;
  }

  // Count of reviews that actually evaluated facility i
  int reviewCountFor(int i) =>
      reviews.where((r) => i < r.scores.length && r.scores[i] != null).length;

  int get score {
    final validAvgs = List.generate(5, (i) => avg(i)).where((a) => a > 0).toList();
    if (validAvgs.isEmpty) return 0;
    return ((validAvgs.reduce((a, b) => a + b) / validAvgs.length) * 20).round();
  }

  Color get color => reviews.isEmpty
      ? const Color(0xFF94A3B8)
      : score >= 70
          ? const Color(0xFF10B981)
          : (score >= 40 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444));

  String get tierLabel => reviews.isEmpty
      ? 'Not Yet Rated'
      : score >= 70
          ? 'Highly Accessible'
          : (score >= 40 ? 'Partially Accessible' : 'Limited Accessibility');

  IconData get tierIcon => reviews.isEmpty
      ? Icons.help_outline_rounded
      : score >= 70
          ? Icons.verified_rounded
          : (score >= 40 ? Icons.info_rounded : Icons.warning_rounded);

  int get photoCount => reviews.where((r) => r.photoPath != null).length;

  int get floorCount => floors.isEmpty ? 1 : floors.length;

  int get totalWashrooms => floors.fold<int>(0, (sum, f) => sum + f.totalWashrooms);

  int get totalAccessibleWashrooms =>
      floors.fold<int>(0, (sum, f) => sum + f.accessibleWashrooms);

  int get totalLifts => floors.fold<int>(0, (sum, f) => sum + f.liftsCount);

  bool get hasLift => totalLifts > 0 || isLiftOperational;

  bool get hasRamp => floors.any((f) => f.hasRamp);

  bool get hasAccessibleWashroom =>
      totalAccessibleWashrooms > 0 || type.toLowerCase().contains('washroom');

  bool get isChargingStation =>
      type.toLowerCase().contains('charging') || name.toLowerCase().contains('charging');

  // ------------------------------------------------------------
  // 🤖 AI SUMMARY ENGINE
  // Synthesizes community sentiment, floor data, and ratings
  // ------------------------------------------------------------
  String generateAiSummary({String tone = 'Standard'}) {
    if (reviews.isEmpty) {
      return '🤖 AI Engine: Abhi tak koi community review record nahi hua hai. Campus accessibility improve karne ke liye pehla feedback aap register karein!';
    }

    final avgs = List.generate(5, avg);
    int best = 0, worst = 0;
    for (var i = 1; i < 5; i++) {
      if (avgs[i] > avgs[best]) best = i;
      if (avgs[i] < avgs[worst]) worst = i;
    }

    final floorSummary = floors.isNotEmpty
        ? ' Building Architecture: ${floors.length} Floors, har floor pe 2 working lifts aur 10 washrooms (2 Divyang-friendly).'
        : '';

    final liftStatus = !isLiftOperational ? ' ⚠️ ALERT: Main lift under maintenance.' : '';

    if (tone == 'Divyang User Guide') {
      return '🤖 AI Accessibility Guide: $name me score $score/100 hai. '
          'Best feature: ${kCategories[best].$2} (${avgs[best].toStringAsFixed(1)}/5). '
          'Caution point: ${kCategories[worst].$2} (${avgs[worst].toStringAsFixed(1)}/5).$floorSummary$liftStatus '
          'Wheelchair users ground ramp aur passenger elevators use kar sakte hain.';
    }

    if (tone == 'Admin Audit') {
      return '🤖 AI Infrastructure Audit: $name received ${reviews.length} peer-verified reviews. '
          'Strongest compliance: ${kCategories[best].$2} @ ${avgs[best].toStringAsFixed(1)}/5. '
          'Target area for campus improvement: ${kCategories[worst].$2} @ ${avgs[worst].toStringAsFixed(1)}/5. '
          '$photoCount photo-proofs archived for verification.';
    }

    // Standard tone
    final mood = score >= 70
        ? 'Campus visitors aur divyang students ke liye highly accessible infrastructure hai.'
        : (score >= 40
            ? 'Partially accessible campus building hai — ramps available hain par thodi planning advisable hai.'
            : 'Accessibility score kam hai — navigation assistance recommended.');

    return '🤖 AI Synthesis (${reviews.length} reviews): $mood '
        'Highlights: ${kCategories[best].$2} (${avgs[best].toStringAsFixed(1)}/5). '
        'Scope for Improvement: ${kCategories[worst].$2} (${avgs[worst].toStringAsFixed(1)}/5).$floorSummary$liftStatus';
  }

  String get aiSummary => generateAiSummary();

  Map<String, dynamic> toJson() => {
        'id': id,
        'n': name,
        'ty': type,
        'la': lat,
        'ln': lng,
        'cu': isCustom,
        'rv': reviews.map((r) => r.toJson()).toList(),
        'fl': floors.map((f) => f.toJson()).toList(),
        'lo': isLiftOperational,
        'an': adminNotice,
      };

  factory Place.fromJson(Map<String, dynamic> j) => Place(
        id: j['id'],
        name: j['n'],
        type: j['ty'],
        lat: j['la'],
        lng: j['ln'],
        isCustom: j['cu'] ?? false,
        reviews: (j['rv'] as List? ?? []).map((e) => Review.fromJson(e)).toList(),
        floors: (j['fl'] as List? ?? []).map((e) => FloorInfo.fromJson(e)).toList(),
        isLiftOperational: j['lo'] ?? true,
        adminNotice: j['an'],
      );
}

// Backward compatibility alias for Profile -> AppUser
typedef Profile = AppUser;

// ------------------------------------------------------------
// IN-APP NOTIFICATION
// ------------------------------------------------------------
class AppNotification {
  final String id;
  final String targetUser;
  final String fromUser;
  final String title;
  final String message;
  final String? placeId;
  final DateTime time;
  bool isRead;

  AppNotification({
    required this.id,
    required this.targetUser,
    required this.fromUser,
    required this.title,
    required this.message,
    this.placeId,
    DateTime? time,
    this.isRead = false,
  }) : time = time ?? DateTime.now();

  String get timeAgo {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'targetUser': targetUser,
        'fromUser': fromUser,
        'title': title,
        'message': message,
        'placeId': placeId,
        'time': time.toIso8601String(),
        'isRead': isRead,
      };

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'] ?? '',
        targetUser: j['targetUser'] ?? '',
        fromUser: j['fromUser'] ?? '',
        title: j['title'] ?? 'Notification',
        message: j['message'] ?? '',
        placeId: j['placeId'],
        time: j['time'] != null ? DateTime.tryParse(j['time']) ?? DateTime.now() : DateTime.now(),
        isRead: j['isRead'] ?? false,
      );
}

// ------------------------------------------------------------
// SAFETY & ANIMAL HAZARD BEACON
// ------------------------------------------------------------
class SafetyHazardBeacon {
  final String id;
  final String type; // 'animal_dog', 'animal_monkey', 'animal_cattle', 'hazard_pothole', 'ramp_blocked'
  final String title;
  final String description;
  final double lat;
  final double lng;
  final DateTime timestamp;
  final String severity; // 'high', 'medium', 'low'
  final String threatClass; // 'dog', 'monkey', 'cattle', 'snake', 'pothole', 'obstacle'
  final String reportedBy;
  final String? photoPath;

  SafetyHazardBeacon({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.lat,
    required this.lng,
    DateTime? timestamp,
    this.severity = 'high',
    this.threatClass = 'dog',
    required this.reportedBy,
    this.photoPath,
  }) : timestamp = timestamp ?? DateTime.now();

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  String get icon {
    switch (threatClass) {
      case 'dog':
        return '🐕';
      case 'monkey':
        return '🐒';
      case 'cattle':
        return '🐂';
      case 'snake':
        return '🐍';
      case 'pothole':
        return '🕳️';
      default:
        return '⚠️';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'description': description,
        'lat': lat,
        'lng': lng,
        'timestamp': timestamp.toIso8601String(),
        'severity': severity,
        'threatClass': threatClass,
        'reportedBy': reportedBy,
        'photoPath': photoPath,
      };

  factory SafetyHazardBeacon.fromJson(Map<String, dynamic> j) => SafetyHazardBeacon(
        id: j['id'] ?? '',
        type: j['type'] ?? 'hazard',
        title: j['title'] ?? 'Hazard Alert',
        description: j['description'] ?? '',
        lat: (j['lat'] as num?)?.toDouble() ?? 23.8143,
        lng: (j['lng'] as num?)?.toDouble() ?? 86.4412,
        timestamp: j['timestamp'] != null ? DateTime.tryParse(j['timestamp']) ?? DateTime.now() : DateTime.now(),
        severity: j['severity'] ?? 'high',
        threatClass: j['threatClass'] ?? 'dog',
        reportedBy: j['reportedBy'] ?? 'Student',
        photoPath: j['photoPath'],
      );
}
