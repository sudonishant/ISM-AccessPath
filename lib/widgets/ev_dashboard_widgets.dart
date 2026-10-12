import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Ultra-Futuristic EV Automotive Color Palette
class EvColors {
  static const Color obsidianBg = Color(0xFF070B14);
  static const Color darkCard = Color(0xFF0D1527);
  static const Color glassSurface = Color(0xBF111E38);
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color electricBlue = Color(0xFF38BDF8);
  static const Color ecoMint = Color(0xFF10B981);
  static const Color neonGreen = Color(0xFF00E599);
  static const Color amberPulse = Color(0xFFFF6B2B);
  static const Color cyberPurple = Color(0xFF8B5CF6);
  static const Color borderGlow = Color(0x3300F0FF);
}

/// Circular EV Energy & Battery Telemetry Dial
/// Direct realization of the Dribbble EV Smart Car Cockpit HUD
class EvBatteryHudDial extends StatelessWidget {
  final double batteryPercent; // 0.0 to 100.0
  final double estimatedRangeKm; // e.g. 14.2
  final String driveMode; // 'Eco Cruise', 'Sport', 'Step-Free Safe'
  final bool isCharging;
  final VoidCallback? onModeToggle;

  const EvBatteryHudDial({
    super.key,
    this.batteryPercent = 88.0,
    this.estimatedRangeKm = 14.2,
    this.driveMode = 'Step-Free Safe',
    this.isCharging = false,
    this.onModeToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? EvColors.darkCard : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? EvColors.borderGlow : const Color(0xFFCBD5E1),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? EvColors.neonCyan.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // ---- Left: Circular Radial Telemetry Gauge ----
          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Custom Gauge Arc Painter
                CustomPaint(
                  size: const Size(110, 110),
                  painter: _EvDialGaugePainter(
                    percent: batteryPercent / 100.0,
                    trackColor: isDark ? const Color(0xFF162544) : const Color(0xFFE2E8F0),
                    activeColor: isCharging ? EvColors.neonGreen : EvColors.neonCyan,
                  ),
                ),
                // Center Telemetry Stats
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${batteryPercent.round()}',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          '%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? EvColors.neonCyan : const Color(0xFF0F766E),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCharging ? Icons.bolt_rounded : Icons.electric_bolt_rounded,
                          size: 13,
                          color: isCharging ? EvColors.neonGreen : EvColors.amberPulse,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          isCharging ? 'CHARGING' : 'BATTERY',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // ---- Right: Telemetry Readouts & Driving Range ----
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Status Badge & Live Mode
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: EvColors.neonGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: EvColors.neonGreen.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: EvColors.neonGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'ONLINE HUD',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: EvColors.neonGreen,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onModeToggle,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark
                              ? EvColors.neonCyan.withValues(alpha: 0.12)
                              : const Color(0xFFCCFBF1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? EvColors.neonCyan : const Color(0xFF0F766E),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.tune_rounded,
                              size: 11,
                              color: isDark ? EvColors.neonCyan : const Color(0xFF0F766E),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              driveMode,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F766E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Range Readout Hero
                Text(
                  '${estimatedRangeKm.toStringAsFixed(1)} KM',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Estimated Wheelchair & EV Range',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),

                const SizedBox(height: 10),

                // Quick Telemetry Tickers
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildMicroMetric(
                        icon: Icons.speed_rounded,
                        label: 'Avg Speed',
                        value: '4.8 km/h',
                        isDark: isDark,
                      ),
                      const SizedBox(width: 14),
                      _buildMicroMetric(
                        icon: Icons.electric_meter_rounded,
                        label: 'Draw',
                        value: '0.12 kW',
                        isDark: isDark,
                      ),
                      const SizedBox(width: 14),
                      _buildMicroMetric(
                        icon: Icons.ramp_right_rounded,
                        label: 'Grade Safe',
                        value: '1:12 Ramp',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicroMetric({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 11,
              color: isDark ? EvColors.neonCyan : const Color(0xFF0F766E),
            ),
            const SizedBox(width: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 8.5,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

/// Custom Dial Gauge Painter for the EV Cockpit Meter
class _EvDialGaugePainter extends CustomPainter {
  final double percent;
  final Color trackColor;
  final Color activeColor;

  _EvDialGaugePainter({
    required this.percent,
    required this.trackColor,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 8;
    const strokeWidth = 9.0;

    // Track arc (270 degrees from -225 to +45)
    const startAngle = 0.75 * math.pi; // 135 deg
    const sweepTotal = 1.5 * math.pi; // 270 deg

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotal,
      false,
      trackPaint,
    );

    // Active Glowing Arc
    final activePaint = Paint()
      ..shader = SweepGradient(
        colors: [
          activeColor.withValues(alpha: 0.6),
          activeColor,
          const Color(0xFF00E599),
        ],
        startAngle: startAngle,
        endAngle: startAngle + sweepTotal,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotal * percent.clamp(0.0, 1.0),
      false,
      activePaint,
    );

    // Outer subtle tick marks
    final tickPaint = Paint()
      ..color = activeColor.withValues(alpha: 0.25)
      ..strokeWidth = 1.5;

    for (int i = 0; i < 18; i++) {
      final angle = startAngle + (sweepTotal / 17) * i;
      final outerX = center.dx + (radius + 6) * math.cos(angle);
      final outerY = center.dy + (radius + 6) * math.sin(angle);
      final innerX = center.dx + (radius + 3) * math.cos(angle);
      final innerY = center.dy + (radius + 3) * math.sin(angle);
      canvas.drawLine(Offset(innerX, innerY), Offset(outerX, outerY), tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _EvDialGaugePainter oldDelegate) =>
      oldDelegate.percent != percent ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.activeColor != activeColor;
}

/// Horizontal EV Status Bar with Smart Telemetry Tiles
class EvTelemetryMetricTilesBar extends StatelessWidget {
  final int totalChargingPorts;
  final int availableChargingPorts;
  final int activeLifts;
  final int totalRestrooms;
  final VoidCallback? onChargingTap;
  final VoidCallback? onLiftsTap;
  final VoidCallback? onRestroomsTap;

  const EvTelemetryMetricTilesBar({
    super.key,
    this.totalChargingPorts = 12,
    this.availableChargingPorts = 9,
    this.activeLifts = 18,
    this.totalRestrooms = 46,
    this.onChargingTap,
    this.onLiftsTap,
    this.onRestroomsTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          // 1. Charging Station Availability Tile
          _buildTelemetryChip(
            isDark: isDark,
            icon: Icons.ev_station_rounded,
            iconColor: EvColors.neonCyan,
            label: 'EV Charging',
            value: '$availableChargingPorts/$totalChargingPorts Ports',
            subValue: 'Rapid 220V Dock',
            glowColor: EvColors.neonCyan,
            onTap: onChargingTap,
          ),
          const SizedBox(width: 10),

          // 2. Elevator Radar Status Tile
          _buildTelemetryChip(
            isDark: isDark,
            icon: Icons.elevator_rounded,
            iconColor: EvColors.ecoMint,
            label: 'Elevators',
            value: '$activeLifts Working',
            subValue: 'Otis & Kone Live',
            glowColor: EvColors.ecoMint,
            onTap: onLiftsTap,
          ),
          const SizedBox(width: 10),

          // 3. Divyang Restroom Radar Tile
          _buildTelemetryChip(
            isDark: isDark,
            icon: Icons.accessible_forward_rounded,
            iconColor: EvColors.amberPulse,
            label: 'Divyang Toilets',
            value: '$totalRestrooms Grab-Bar',
            subValue: 'Emergency Alert',
            glowColor: EvColors.amberPulse,
            onTap: onRestroomsTap,
          ),
          const SizedBox(width: 10),

          // 4. Step-Free Zero-Obstacle Path
          _buildTelemetryChip(
            isDark: isDark,
            icon: Icons.alt_route_rounded,
            iconColor: EvColors.cyberPurple,
            label: 'Campus Route',
            value: '100% Flat',
            subValue: 'Zero-Stair Guarantee',
            glowColor: EvColors.cyberPurple,
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryChip({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String subValue,
    required Color glowColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? EvColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? glowColor.withValues(alpha: 0.3)
                : const Color(0xFFE2E8F0),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? glowColor.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  subValue,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w500,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// EV Charging Station Live Beacon Card
class EvChargingBeaconCard extends StatelessWidget {
  final String stationName;
  final String location;
  final int totalPorts;
  final int availablePorts;
  final String powerRating; // e.g. "220V Rapid AC / Fast DC"
  final VoidCallback onNavigate;

  const EvChargingBeaconCard({
    super.key,
    required this.stationName,
    required this.location,
    this.totalPorts = 4,
    this.availablePorts = 3,
    this.powerRating = '220V Rapid • 100% Green Solar',
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF091428), const Color(0xFF0D223F)]
              : [const Color(0xFFE0F2FE), const Color(0xFFF0FDF4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: EvColors.neonCyan.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: EvColors.neonCyan.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: EvColors.neonCyan.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.electric_bolt_rounded,
                  color: EvColors.neonCyan,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stationName,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: EvColors.neonGreen.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: EvColors.neonGreen.withValues(alpha: 0.6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flash_on_rounded, size: 12, color: EvColors.neonGreen),
                    const SizedBox(width: 3),
                    Text(
                      '$availablePorts/$totalPorts Free',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: EvColors.neonGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.speed_rounded, size: 13, color: isDark ? EvColors.electricBlue : const Color(0xFF0F766E)),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  powerRating,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onNavigate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [EvColors.neonCyan, Color(0xFF0284C7)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: EvColors.neonCyan.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.navigation_rounded, size: 12, color: Colors.black),
                      SizedBox(width: 4),
                      Text(
                        'Navigate Bay',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
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
  }
}

/// EV Turn-by-Turn Route Guidance HUD Banner
class EvRouteGuidanceHud extends StatelessWidget {
  final String destinationName;
  final double distanceMeters;
  final String etaMinutes;
  final String nextManeuver; // e.g. "Bear right onto NLHC ramp (1:12)"
  final int batteryCostPercent; // e.g. 2%
  final VoidCallback onCancel;

  const EvRouteGuidanceHud({
    super.key,
    required this.destinationName,
    required this.distanceMeters,
    required this.etaMinutes,
    required this.nextManeuver,
    this.batteryCostPercent = 2,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? EvColors.obsidianBg.withValues(alpha: 0.94) : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: EvColors.neonCyan.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: EvColors.neonCyan.withValues(alpha: 0.25),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [EvColors.neonCyan, Color(0xFF0284C7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.turn_slight_right_rounded, color: Colors.black, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nextManeuver,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Toward $destinationName • Step-Free Verified',
                      style: const TextStyle(
                        fontSize: 11,
                        color: EvColors.neonGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                color: isDark ? Colors.white70 : Colors.black54,
                onPressed: onCancel,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D182E) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRouteStat(
                  icon: Icons.timer_outlined,
                  label: 'ETA',
                  value: etaMinutes,
                  isDark: isDark,
                ),
                _buildRouteStat(
                  icon: Icons.straighten_rounded,
                  label: 'Distance',
                  value: '${distanceMeters.round()} m',
                  isDark: isDark,
                ),
                _buildRouteStat(
                  icon: Icons.bolt_rounded,
                  label: 'Battery Cost',
                  value: '-$batteryCostPercent%',
                  isDark: isDark,
                  valColor: EvColors.amberPulse,
                ),
                _buildRouteStat(
                  icon: Icons.accessibility_new_rounded,
                  label: 'Incline',
                  value: '0 Stairs',
                  isDark: isDark,
                  valColor: EvColors.neonGreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteStat({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    Color? valColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: isDark ? EvColors.neonCyan : const Color(0xFF0F766E)),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: valColor ?? (isDark ? Colors.white : const Color(0xFF0F172A)),
          ),
        ),
      ],
    );
  }
}
