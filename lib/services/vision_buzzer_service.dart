// ============================================================
// vision_buzzer_service.dart — Acoustic Sound & Light Buzzer
// IIT (ISM) Dhanbad Campus Safety & Deterrent Alarm System
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ThreatType {
  strayDog,
  monkey,
  cattle,
  snake,
  potholeObstacle,
  clearPath,
}

class DetectedHazard {
  final String label;
  final ThreatType type;
  final double confidence; // 0.0 - 1.0
  final Rect boundingBox;
  final double distanceMeters;
  final String advisory;

  const DetectedHazard({
    required this.label,
    required this.type,
    required this.confidence,
    required this.boundingBox,
    required this.distanceMeters,
    required this.advisory,
  });
}

class ThreatProfile {
  final ThreatType type;
  final String name;
  final String hindiName;
  final String icon;
  final Color threatColor;
  final String deterrentSoundName;
  final String safetyProtocol;
  final int beepCount;
  final int beepIntervalMs;

  const ThreatProfile({
    required this.type,
    required this.name,
    required this.hindiName,
    required this.icon,
    required this.threatColor,
    required this.deterrentSoundName,
    required this.safetyProtocol,
    required this.beepCount,
    required this.beepIntervalMs,
  });
}

class VisionBuzzerService extends ChangeNotifier {
  VisionBuzzerService._();
  static final VisionBuzzerService instance = VisionBuzzerService._();

  static const Map<ThreatType, ThreatProfile> profiles = {
    ThreatType.strayDog: ThreatProfile(
      type: ThreatType.strayDog,
      name: 'Stray Dog / Pack',
      hindiName: 'आवारा कुत्ता (Stray Dog)',
      icon: '🐕',
      threatColor: Color(0xFFEF4444),
      deterrentSoundName: 'Ultrasonic Pulse & Warning Buzzer',
      safetyProtocol: 'Do not run. Avoid direct eye stare. Slowly back away towards nearest ramp or lit doorway.',
      beepCount: 4,
      beepIntervalMs: 140,
    ),
    ThreatType.monkey: ThreatProfile(
      type: ThreatType.monkey,
      name: 'Aggressive Monkey',
      hindiName: 'आक्रामक बंदर (Monkey)',
      icon: '🐒',
      threatColor: Color(0xFFF97316),
      deterrentSoundName: 'High-Decibel Deterrent Siren',
      safetyProtocol: 'Conceal food/bags immediately. Do not bare teeth or shout. Maintain safe 5m clearance.',
      beepCount: 5,
      beepIntervalMs: 110,
    ),
    ThreatType.cattle: ThreatProfile(
      type: ThreatType.cattle,
      name: 'Stray Cattle / Bull',
      hindiName: 'मवेशी / सांड (Stray Cattle)',
      icon: '🐂',
      threatColor: Color(0xFFEAB308),
      deterrentSoundName: 'Low-Frequency Caution Horn',
      safetyProtocol: 'Give wide berth (minimum 3 meters). Beware of sudden swiveling on narrow ramps.',
      beepCount: 2,
      beepIntervalMs: 350,
    ),
    ThreatType.snake: ThreatProfile(
      type: ThreatType.snake,
      name: 'Reptile / Snake',
      hindiName: 'सांप (Reptile)',
      icon: '🐍',
      threatColor: Color(0xFFDC2626),
      deterrentSoundName: 'Rapid Emergency Warble',
      safetyProtocol: 'Halt immediately! Stomp feet firmly to generate ground vibrations. Contact campus security.',
      beepCount: 6,
      beepIntervalMs: 90,
    ),
    ThreatType.potholeObstacle: ThreatProfile(
      type: ThreatType.potholeObstacle,
      name: 'Broken Path / Pothole',
      hindiName: 'गड्ढा / टूटा रास्ता (Obstacle)',
      icon: '🕳️',
      threatColor: Color(0xFF3B82F6),
      deterrentSoundName: 'Proximity Caution Clicker',
      safetyProtocol: 'Wheelchair tip hazard. Detour to adjacent smooth tactile tiles.',
      beepCount: 2,
      beepIntervalMs: 200,
    ),
    ThreatType.clearPath: ThreatProfile(
      type: ThreatType.clearPath,
      name: 'Clear Access Path',
      hindiName: 'सुरक्षित रास्ता (Clear)',
      icon: '✅',
      threatColor: Color(0xFF10B981),
      deterrentSoundName: 'Safe Chime',
      safetyProtocol: 'Path is unobstructed and step-free. Safe to proceed.',
      beepCount: 1,
      beepIntervalMs: 150,
    ),
  };

  // State
  bool _isSoundBuzzerActive = false;
  bool _isLightStrobeActive = false;
  bool _strobeVisible = false;
  Color _currentStrobeColor = const Color(0xFFEF4444);
  Timer? _strobeTimer;
  Timer? _buzzerTimer;
  ThreatProfile? _lastActiveProfile;

  bool get isSoundBuzzerActive => _isSoundBuzzerActive;
  bool get isLightStrobeActive => _isLightStrobeActive;
  bool get strobeVisible => _strobeVisible;
  Color get currentStrobeColor => _currentStrobeColor;
  ThreatProfile? get lastActiveProfile => _lastActiveProfile;

  /// Trigger dynamic audio sound buzzer and haptic deterrent pulses
  Future<void> triggerSoundBuzzer(ThreatType type) async {
    final profile = profiles[type] ?? profiles[ThreatType.strayDog]!;
    _lastActiveProfile = profile;
    _isSoundBuzzerActive = true;
    notifyListeners();

    // Execute rhythmic buzzer pulse sequence
    for (int i = 0; i < profile.beepCount; i++) {
      try {
        await SystemSound.play(SystemSoundType.alert);
      } catch (_) {}

      // Multi-layer haptics for sensory accessibility
      try {
        if (type == ThreatType.strayDog || type == ThreatType.snake) {
          HapticFeedback.heavyImpact();
        } else if (type == ThreatType.monkey) {
          HapticFeedback.vibrate();
        } else {
          HapticFeedback.mediumImpact();
        }
      } catch (_) {}

      await Future.delayed(Duration(milliseconds: profile.beepIntervalMs));
    }

    _isSoundBuzzerActive = false;
    notifyListeners();
  }

  /// Trigger visual light buzzer / high-intensity screen strobe
  void startLightStrobe(ThreatType type, {Duration duration = const Duration(seconds: 4)}) {
    final profile = profiles[type] ?? profiles[ThreatType.strayDog]!;
    _currentStrobeColor = profile.threatColor;
    _isLightStrobeActive = true;
    _strobeTimer?.cancel();
    _buzzerTimer?.cancel();

    // Flash screen at 8 Hz (125ms intervals)
    _strobeTimer = Timer.periodic(const Duration(milliseconds: 125), (t) {
      _strobeVisible = !_strobeVisible;
      notifyListeners();
    });

    // Auto turn off after duration
    _buzzerTimer = Timer(duration, () {
      stopLightStrobe();
    });
  }

  /// Stops visual strobe
  void stopLightStrobe() {
    _strobeTimer?.cancel();
    _strobeTimer = null;
    _isLightStrobeActive = false;
    _strobeVisible = false;
    notifyListeners();
  }

  /// Combined Emergency Deterrent: Sound Buzzer + Light Strobe Flasher
  Future<void> triggerEmergencyDeterrent(ThreatType type) async {
    startLightStrobe(type, duration: const Duration(seconds: 5));
    await triggerSoundBuzzer(type);
  }

  @override
  void dispose() {
    _strobeTimer?.cancel();
    _buzzerTimer?.cancel();
    super.dispose();
  }
}
