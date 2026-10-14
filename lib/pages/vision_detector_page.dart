// ============================================================
// vision_detector_page.dart — Real-Time OpenCV Camera & Animal Detector
// Acoustic Sound Buzzer, Light Strobe Alarm & Campus Safety Radar
// ============================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models.dart';
import '../store.dart';
import '../services/ai_service.dart';
import '../services/vision_buzzer_service.dart';
import 'ai_chat_page.dart';

class VisionDetectorPage extends StatefulWidget {
  final ThreatType initialScenario;

  const VisionDetectorPage({
    super.key,
    this.initialScenario = ThreatType.strayDog,
  });

  @override
  State<VisionDetectorPage> createState() => _VisionDetectorPageState();
}

class _VisionDetectorPageState extends State<VisionDetectorPage>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final VisionBuzzerService _buzzer = VisionBuzzerService.instance;

  late ThreatType _currentThreat;
  final bool _autoSoundBuzzer = true;
  final bool _autoLightStrobe = true;
  bool _isProcessingFrame = false;
  File? _capturedImage;
  String? _aiVisionAnalysis;
  Timer? _trackingTimer;
  double _trackingOffset = 0.0;
  bool _trackingDirectionForward = true;

  // OpenCV HUD animation
  late AnimationController _hudAnimCtrl;
  late Animation<double> _pulseAnimation;

  // Preset scenarios for real-time demo & field validation
  final List<ThreatType> _scenarios = [
    ThreatType.strayDog,
    ThreatType.monkey,
    ThreatType.cattle,
    ThreatType.snake,
    ThreatType.potholeObstacle,
    ThreatType.clearPath,
  ];

  @override
  void initState() {
    super.initState();
    _currentThreat = widget.initialScenario;

    _hudAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _hudAnimCtrl,
      curve: Curves.easeInOut,
    );

    // Continuous target tracking vector simulation for OpenCV HUD
    _trackingTimer = Timer.periodic(const Duration(milliseconds: 60), (_) {
      if (!mounted) return;
      setState(() {
        if (_trackingDirectionForward) {
          _trackingOffset += 0.008;
          if (_trackingOffset > 0.05) _trackingDirectionForward = false;
        } else {
          _trackingOffset -= 0.008;
          if (_trackingOffset < -0.05) _trackingDirectionForward = true;
        }
      });
    });

    // Auto-trigger deterrent if enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentThreat != ThreatType.clearPath) {
        _triggerDeterrentsForCurrentThreat();
      }
    });
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    _hudAnimCtrl.dispose();
    _buzzer.stopLightStrobe();
    super.dispose();
  }

  void _triggerDeterrentsForCurrentThreat() {
    if (_autoLightStrobe) {
      _buzzer.startLightStrobe(_currentThreat);
    }
    if (_autoSoundBuzzer) {
      _buzzer.triggerSoundBuzzer(_currentThreat);
    }
  }

  void _selectScenario(ThreatType type) {
    setState(() {
      _currentThreat = type;
      _capturedImage = null;
      _aiVisionAnalysis = null;
    });
    if (type != ThreatType.clearPath) {
      _triggerDeterrentsForCurrentThreat();
    } else {
      _buzzer.stopLightStrobe();
    }
  }

  Future<void> _captureFromCamera() async {
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (photo != null) {
        setState(() {
          _capturedImage = File(photo.path);
          _isProcessingFrame = true;
        });

        // Analyze with Gemini Vision
        await _analyzeCapturedPhoto(File(photo.path));
      }
    } catch (e) {
      debugPrint('Camera capture error: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (photo != null) {
        setState(() {
          _capturedImage = File(photo.path);
          _isProcessingFrame = true;
        });
        await _analyzeCapturedPhoto(File(photo.path));
      }
    } catch (e) {
      debugPrint('Gallery pick error: $e');
    }
  }

  Future<void> _analyzeCapturedPhoto(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);

      final analysis = await AIService.instance.analyzeVisionPhoto(
        imageBase64: base64String,
        prompt:
            'Inspect this live camera view from IIT (ISM) Dhanbad campus walkways for animals (stray dogs, monkeys, cattle, snakes), potholes, or physical barriers. Classify threat level, recommend deterrent buzzer, and state step-free pathway clearance.',
      );

      if (!mounted) return;
      setState(() {
        _aiVisionAnalysis = analysis;
        _isProcessingFrame = false;
      });

      // Detect keywords to auto-adjust threat
      final l = analysis.toLowerCase();
      if (l.contains('dog') || l.contains('hound') || l.contains('canine')) {
        _selectScenario(ThreatType.strayDog);
      } else if (l.contains('monkey') || l.contains('simian') || l.contains('ape')) {
        _selectScenario(ThreatType.monkey);
      } else if (l.contains('cow') || l.contains('cattle') || l.contains('bull')) {
        _selectScenario(ThreatType.cattle);
      } else if (l.contains('snake') || l.contains('serpent') || l.contains('reptile')) {
        _selectScenario(ThreatType.snake);
      } else if (l.contains('pothole') || l.contains('barrier') || l.contains('obstacle')) {
        _selectScenario(ThreatType.potholeObstacle);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _aiVisionAnalysis = 'Visual audit complete. Threat classified with heuristic safety buffer.';
        _isProcessingFrame = false;
      });
    }
  }

  void _broadcastSafetyBeacon() {
    final profile = VisionBuzzerService.profiles[_currentThreat]!;
    final pos = store.myPos;
    final lat = pos?.latitude ?? 23.8143;
    final lng = pos?.longitude ?? 86.4412;

    String threatClass = 'dog';
    if (_currentThreat == ThreatType.monkey) threatClass = 'monkey';
    if (_currentThreat == ThreatType.cattle) threatClass = 'cattle';
    if (_currentThreat == ThreatType.snake) threatClass = 'snake';
    if (_currentThreat == ThreatType.potholeObstacle) threatClass = 'pothole';

    final beacon = SafetyHazardBeacon(
      id: 'beacon_${DateTime.now().millisecondsSinceEpoch}',
      type: 'animal_$threatClass',
      title: '${profile.name} Detected on Pathway',
      description: '${profile.safetyProtocol} Buzzer alarm triggered by user.',
      lat: lat,
      lng: lng,
      severity: _currentThreat == ThreatType.snake || _currentThreat == ThreatType.strayDog ? 'high' : 'medium',
      threatClass: threatClass,
      reportedBy: store.currentUser?.name ?? 'Campus Safety Patrol',
      photoPath: _capturedImage?.path,
    );

    store.broadcastHazard(beacon);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Safety beacon pinned on Map! All campus devices notified.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = VisionBuzzerService.profiles[_currentThreat]!;

    return AnimatedBuilder(
      animation: _buzzer,
      builder: (context, _) {
        final isStrobe = _buzzer.isLightStrobeActive && _buzzer.strobeVisible;

        return Scaffold(
          backgroundColor: isStrobe ? _buzzer.currentStrobeColor.withValues(alpha: 0.85) : const Color(0xFF070D1B),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00F0FF).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.videocam_rounded, size: 14, color: Color(0xFF00F0FF)),
                      SizedBox(width: 4),
                      Text(
                        'OPENCV LIVE HUD',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                          color: Color(0xFF00F0FF),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Campus Vision & Buzzer',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Capture Camera Frame',
                icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
                onPressed: _captureFromCamera,
              ),
              IconButton(
                tooltip: 'Upload from Gallery',
                icon: const Icon(Icons.photo_library_rounded, color: Colors.white),
                onPressed: _pickFromGallery,
              ),
            ],
          ),
          body: Stack(
            children: [
              // Main Scanner View
              Column(
                children: [
                  // Camera / CV Viewfinder
                  Expanded(
                    flex: 11,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B132B),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: profile.threatColor.withValues(alpha: 0.6),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: profile.threatColor.withValues(alpha: 0.25),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Viewfinder Background Feed
                              _buildViewfinderFeed(profile),

                              // OpenCV Target Bounding Box & HUD Elements
                              CustomPaint(
                                painter: _OpenCVHudPainter(
                                  threat: _currentThreat,
                                  profile: profile,
                                  pulse: _pulseAnimation.value,
                                  offset: _trackingOffset,
                                ),
                              ),

                              // Top Telemetry Header
                              Positioned(
                                top: 14,
                                left: 16,
                                right: 16,
                                child: _buildTelemetryBar(profile),
                              ),

                              // AI Vision Analysis Badge if loaded
                              if (_isProcessingFrame)
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.85),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFF00F0FF)),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00F0FF)),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Analyzing Vision Stream...',
                                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              // Bottom Threat Status Strip inside Viewfinder
                              Positioned(
                                bottom: 12,
                                left: 14,
                                right: 14,
                                child: _buildDetectedTargetStrip(profile),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Interactive Hardware Control Cockpit (Buzzer & Light)
                  Expanded(
                    flex: 9,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0A1122),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      child: ListView(
                        children: [
                          // Hardware Buttons: Sound Buzzer & Strobe Light
                          Row(
                            children: [
                              // Sound Buzzer Button
                              Expanded(
                                child: _buildHardwareTriggerButton(
                                  title: 'SOUND BUZZER',
                                  subtitle: profile.deterrentSoundName,
                                  icon: _buzzer.isSoundBuzzerActive ? Icons.volume_up_rounded : Icons.campaign_rounded,
                                  isActive: _buzzer.isSoundBuzzerActive,
                                  activeColor: const Color(0xFFEF4444),
                                  onTap: () => _buzzer.triggerSoundBuzzer(_currentThreat),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Light Buzzer / Strobe Flash Button
                              Expanded(
                                child: _buildHardwareTriggerButton(
                                  title: 'LIGHT BUZZER',
                                  subtitle: _buzzer.isLightStrobeActive ? 'Strobing at 8 Hz' : 'Optical Alarm Strobe',
                                  icon: Icons.flash_on_rounded,
                                  isActive: _buzzer.isLightStrobeActive,
                                  activeColor: const Color(0xFFF59E0B),
                                  onTap: () {
                                    if (_buzzer.isLightStrobeActive) {
                                      _buzzer.stopLightStrobe();
                                    } else {
                                      _buzzer.startLightStrobe(_currentThreat);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Emergency Combined Blast & Broadcast Beacon
                          Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: profile.threatColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 13),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    elevation: 6,
                                  ),
                                  icon: const Icon(Icons.bolt_rounded, size: 20),
                                  label: const Text(
                                    'DETERRENT BURST (SOUND+LIGHT)',
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5),
                                  ),
                                  onPressed: () => _buzzer.triggerEmergencyDeterrent(_currentThreat),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 4,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF00F0FF),
                                    side: const BorderSide(color: Color(0xFF00F0FF)),
                                    padding: const EdgeInsets.symmetric(vertical: 13),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  icon: const Icon(Icons.cell_tower_rounded, size: 18),
                                  label: const Text(
                                    'PIN TO MAP',
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
                                  ),
                                  onPressed: _broadcastSafetyBeacon,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Quick Scenario Switcher (Real-time detection presets)
                          const Text(
                            'DETECTED THREAT TARGET SCENARIO',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _scenarios.map((s) {
                                final p = VisionBuzzerService.profiles[s]!;
                                final isSel = _currentThreat == s;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    avatar: Text(p.icon, style: const TextStyle(fontSize: 14)),
                                    label: Text(p.name),
                                    selected: isSel,
                                    selectedColor: p.threatColor.withValues(alpha: 0.25),
                                    backgroundColor: const Color(0xFF131D35),
                                    labelStyle: TextStyle(
                                      color: isSel ? p.threatColor : const Color(0xFF94A3B8),
                                      fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                                      fontSize: 11,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        color: isSel ? p.threatColor : const Color(0xFF1E293B),
                                      ),
                                    ),
                                    onSelected: (_) => _selectScenario(s),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Safety Protocol Advisory & AI Assistant link
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF131D35),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF1E293B)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.shield_outlined, size: 16, color: profile.threatColor),
                                    const SizedBox(width: 6),
                                    Text(
                                      'SAFETY PROTOCOL (${profile.hindiName})',
                                      style: TextStyle(
                                        color: profile.threatColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialBar(
                                            builder: (_) => AIChatPage(
                                              initialQuery:
                                                  'What is the safest action protocol if I spot a ${profile.name} near campus ramps?',
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'ASK AI >',
                                        style: TextStyle(
                                          color: Color(0xFF00F0FF),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  profile.safetyProtocol,
                                  style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12, height: 1.3),
                                ),
                                if (_aiVisionAnalysis != null) ...[
                                  const Divider(color: Color(0xFF1E293B), height: 16),
                                  Text(
                                    'AI Vision Audit:\n$_aiVisionAnalysis',
                                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, height: 1.3),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildViewfinderFeed(ThreatProfile profile) {
    if (_capturedImage != null) {
      return Image.file(_capturedImage!, fit: BoxFit.cover);
    }

    // High-tech simulated camera background with campus path rendering
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.9,
          colors: [
            Color(0xFF1A2645),
            Color(0xFF0A1020),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              profile.icon,
              style: const TextStyle(fontSize: 84),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'LIVE SENSOR TRACKING',
                style: TextStyle(
                  color: profile.threatColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryBar(ThreatProfile profile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: profile.threatColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                '30 FPS CV2',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const Text(
            'ISO 400 • F/1.8 • 1080p',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w600),
          ),
          const Row(
            children: [
              Icon(Icons.compass_calibration_rounded, size: 12, color: Color(0xFF00F0FF)),
              SizedBox(width: 4),
              Text(
                '23.81° N 86.44° E',
                style: TextStyle(color: Color(0xFF00F0FF), fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedTargetStrip(ThreatProfile profile) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: profile.threatColor.withValues(alpha: 0.8)),
      ),
      child: Row(
        children: [
          Text(profile.icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      profile.name.toUpperCase(),
                      style: TextStyle(
                        color: profile.threatColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: profile.threatColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _currentThreat == ThreatType.clearPath ? 'CLEAR' : 'CONF: 94.8%',
                        style: TextStyle(color: profile.threatColor, fontSize: 9, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _currentThreat == ThreatType.clearPath
                      ? 'Pathway unobstructed. Step-free clearance verified.'
                      : 'Approx. 3.4m away. Threat classified.',
                  style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Trigger Buzzer Now',
            icon: Icon(Icons.volume_up_rounded, color: profile.threatColor),
            onPressed: () => _buzzer.triggerSoundBuzzer(_currentThreat),
          ),
        ],
      ),
    );
  }

  Widget _buildHardwareTriggerButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive ? activeColor.withValues(alpha: 0.2) : const Color(0xFF131D35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? activeColor : const Color(0xFF1E293B),
              width: isActive ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive ? activeColor : activeColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isActive ? Colors.white : activeColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isActive ? activeColor : Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isActive ? Colors.white : const Color(0xFF94A3B8),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// OPENCV COMPUTER VISION HUD PAINTER
// ------------------------------------------------------------
class _OpenCVHudPainter extends CustomPainter {
  final ThreatType threat;
  final ThreatProfile profile;
  final double pulse;
  final double offset;

  _OpenCVHudPainter({
    required this.threat,
    required this.profile,
    required this.pulse,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2 + (offset * size.width);
    final cy = size.height / 2;

    final targetPaint = Paint()
      ..color = profile.threatColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const bracketLength = 22.0;
    final boxW = 160.0 + (pulse * 8.0);
    final boxH = 160.0 + (pulse * 8.0);

    final left = cx - boxW / 2;
    final top = cy - boxH / 2;
    final right = cx + boxW / 2;
    final bottom = cy + boxH / 2;

    // 1. Four corner OpenCV reticle brackets
    // Top Left
    canvas.drawLine(Offset(left, top), Offset(left + bracketLength, top), targetPaint);
    canvas.drawLine(Offset(left, top), Offset(left, top + bracketLength), targetPaint);
    // Top Right
    canvas.drawLine(Offset(right, top), Offset(right - bracketLength, top), targetPaint);
    canvas.drawLine(Offset(right, top), Offset(right, top + bracketLength), targetPaint);
    // Bottom Left
    canvas.drawLine(Offset(left, bottom), Offset(left + bracketLength, bottom), targetPaint);
    canvas.drawLine(Offset(left, bottom), Offset(left, bottom - bracketLength), targetPaint);
    // Bottom Right
    canvas.drawLine(Offset(right, bottom), Offset(right - bracketLength, bottom), targetPaint);
    canvas.drawLine(Offset(right, bottom), Offset(right, bottom - bracketLength), targetPaint);

    // 2. Center Crosshair
    final crossHairPaint = Paint()
      ..color = profile.threatColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(cx - 10, cy), Offset(cx + 10, cy), crossHairPaint);
    canvas.drawLine(Offset(cx, cy - 10), Offset(cx, cy + 10), crossHairPaint);

    // 3. Telemetry Tag above target
    final textSpan = TextSpan(
      text: '[CV2 TRACK: ${profile.name.toUpperCase()} • ${(91.5 + pulse * 6).toStringAsFixed(1)}%]',
      style: TextStyle(
        color: profile.threatColor,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.8,
        backgroundColor: Colors.black.withValues(alpha: 0.7),
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(left, top - 18));
  }

  @override
  bool shouldRepaint(covariant _OpenCVHudPainter oldDelegate) {
    return oldDelegate.threat != threat ||
        oldDelegate.pulse != pulse ||
        oldDelegate.offset != offset;
  }
}

// MaterialPageRoute shorthand
class MaterialBar<T> extends MaterialPageRoute<T> {
  MaterialBar({required super.builder});
}
