// ============================================================
// map_page.dart — Dynamic Public Campus Map & Facility Explorer
// Ultra-Modern Frosted Glassmorphism UI (Dark & Light)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models.dart';
import '../store.dart';
import '../widgets/glass_container.dart';
import 'add_place_page.dart';
import 'detail_page.dart';
import 'vision_detector_page.dart';
import '../services/vision_buzzer_service.dart';
import 'ai_chat_page.dart';
import '../widgets/ev_dashboard_widgets.dart';

class MapPage extends StatefulWidget {
  final Place? initialPlace;
  final bool autoStartNav;

  const MapPage({
    super.key,
    this.initialPlace,
    this.autoStartNav = false,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool satellite = false;
  final mapCtrl = MapController();
  Place? _selectedPlace;
  String _activeFilter = 'All';
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isNavigating = false;

  // IIT (ISM) Dhanbad Campus Coordinates
  static const campusCenter = LatLng(23.8152, 86.4415);
  static const osmUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const satUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

  @override
  void initState() {
    super.initState();
    if (widget.initialPlace != null) {
      _selectedPlace = widget.initialPlace;
      _isNavigating = widget.autoStartNav;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _centerOn(LatLng(widget.initialPlace!.lat, widget.initialPlace!.lng));
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _centerOn(LatLng point) {
    mapCtrl.move(point, 17.2);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final query = _searchCtrl.text.trim().toLowerCase();

        // Dynamic filtering based on public facilities & search query
        final visiblePlaces = store.places.where((p) {
          // Search query matching
          if (query.isNotEmpty) {
            final matchesName = p.name.toLowerCase().contains(query);
            final matchesType = p.type.toLowerCase().contains(query);
            if (!matchesName && !matchesType) return false;
          }

          // Category filter matching
          switch (_activeFilter) {
            case '⚡ Charging':
              return p.isChargingStation;
            case '🚻 Washrooms':
              return p.type.toLowerCase() == 'washroom' || p.hasAccessibleWashroom;
            case '🛗 Lifts':
              return p.hasLift;
            case '♿ Ramps':
              return p.hasRamp;
            case '🏢 Hostels':
              return p.type.toLowerCase() == 'hostel';
            case '🎓 Academic':
              return p.type.toLowerCase() == 'academic' || p.type.toLowerCase() == 'library';
            case '☕ Food':
              return p.type.toLowerCase() == 'food';
            case 'All':
            default:
              return true;
          }
        }).toList();

        return Scaffold(
          body: Stack(
            children: [
              // ---- OpenStreetMap / Satellite Layer ----
              FlutterMap(
                mapController: mapCtrl,
                options: MapOptions(
                  initialCenter: campusCenter,
                  initialZoom: 16.0,
                  minZoom: 14.0,
                  maxZoom: 19.0,
                  onTap: (_, __) => setState(() => _selectedPlace = null),
                  onLongPress: (_, ll) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddPlacePage(lat: ll.latitude, lng: ll.longitude),
                    ),
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: satellite ? satUrl : osmUrl,
                    userAgentPackageName: 'com.example.accesspath',
                  ),

                  // Reachability Circle (Electric Wheelchair & Mobility Range)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: store.myPos != null
                            ? LatLng(store.myPos!.latitude, store.myPos!.longitude)
                            : campusCenter,
                        radius: 350,
                        useRadiusInMeter: true,
                        color: const Color(0x1800F0FF),
                        borderColor: const Color(0x6600F0FF),
                        borderStrokeWidth: 1.5,
                      ),
                    ],
                  ),

                  // Turn-by-Turn Glowing Polyline Layer when navigating
                  if (_isNavigating && _selectedPlace != null)
                    PolylineLayer(
                      polylines: [
                        // Outer neon cyan glow
                        Polyline(
                          points: [
                            store.myPos != null
                                ? LatLng(store.myPos!.latitude, store.myPos!.longitude)
                                : campusCenter,
                            LatLng(_selectedPlace!.lat, _selectedPlace!.lng),
                          ],
                          strokeWidth: 8.0,
                          color: const Color(0x6600F0FF),
                        ),
                        // Core electric cyan route
                        Polyline(
                          points: [
                            store.myPos != null
                                ? LatLng(store.myPos!.latitude, store.myPos!.longitude)
                                : campusCenter,
                            LatLng(_selectedPlace!.lat, _selectedPlace!.lng),
                          ],
                          strokeWidth: 3.5,
                          color: const Color(0xFF00F0FF),
                        ),
                      ],
                    ),

                  // Markers Layer
                  MarkerLayer(
                    markers: [
                      ...visiblePlaces.map((p) {
                        final isSelected = _selectedPlace?.id == p.id;
                        final isCharging = p.isChargingStation;
                        final isWashroom = p.type.toLowerCase() == 'washroom';
                        final isHostel = p.type.toLowerCase() == 'hostel';

                        return Marker(
                          point: LatLng(p.lat, p.lng),
                          width: isSelected ? 76 : (isCharging ? 64 : 56),
                          height: isSelected ? 76 : (isCharging ? 64 : 56),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedPlace = p);
                              _centerOn(LatLng(p.lat, p.lng));
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Pill badge showing type, dock or score
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFFF6B2B)
                                          : (isCharging
                                              ? const Color(0xFF00F0FF)
                                              : (isWashroom
                                                  ? const Color(0xFF38BDF8)
                                                  : (isHostel ? const Color(0xFF10B981) : const Color(0xFF64748B)))),
                                      width: isSelected ? 2.0 : 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isCharging
                                            ? const Color(0xFF00F0FF).withValues(alpha: 0.4)
                                            : Colors.black.withValues(alpha: 0.25),
                                        blurRadius: isCharging ? 8 : 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    isCharging
                                        ? '⚡ DOCK'
                                        : (isWashroom
                                            ? '🚻 ${p.totalAccessibleWashrooms} Acc'
                                            : (p.reviews.isEmpty ? 'NEW' : '${p.score}')),
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected
                                          ? const Color(0xFFFF6B2B)
                                          : (isCharging
                                              ? const Color(0xFF00F0FF)
                                              : (isDark ? Colors.white : const Color(0xFF0F172A))),
                                    ),
                                  ),
                                ),
                                Icon(
                                  isCharging
                                      ? Icons.ev_station_rounded
                                      : (isWashroom
                                          ? Icons.wc_rounded
                                          : (isHostel ? Icons.domain_rounded : Icons.location_on_rounded)),
                                  color: isSelected
                                      ? const Color(0xFFFF6B2B)
                                      : (isCharging
                                          ? const Color(0xFF00F0FF)
                                          : (isWashroom
                                              ? const Color(0xFF0284C7)
                                              : (isHostel ? const Color(0xFF10B981) : const Color(0xFF0F766E)))),
                                  size: isSelected ? 40 : (isCharging ? 34 : 30),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      // Active Safety Hazard & Animal Detection Markers
                      ...store.activeHazards.map((hz) {
                        return Marker(
                          point: LatLng(hz.lat, hz.lng),
                          width: 58,
                          height: 58,
                          child: GestureDetector(
                            onTap: () {
                              _showHazardBottomSheet(context, hz, isDark);
                              _centerOn(LatLng(hz.lat, hz.lng));
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white, width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFEF4444).withValues(alpha: 0.6),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(hz.icon, style: const TextStyle(fontSize: 13)),
                                      const SizedBox(width: 3),
                                      const Text(
                                        'ALERT',
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      // User GPS Location Pin
                      if (store.myPos != null)
                        Marker(
                          point: LatLng(store.myPos!.latitude, store.myPos!.longitude),
                          width: 28,
                          height: 28,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF00F0FF),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00F0FF).withValues(alpha: 0.6),
                                  blurRadius: 10,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // ---- Top Glassmorphic Search & Category Filters ----
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Floating Search Bar & Layer Switch
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        borderRadius: 24,
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded, size: 20, color: Color(0xFFFF6B2B)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search campus landmarks, washrooms, lifts...',
                                  hintStyle: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            if (_searchCtrl.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _searchCtrl.clear();
                                  setState(() {});
                                },
                                child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                              ),
                            const SizedBox(width: 6),
                            // Map Layer Toggle (Satellite / Vector)
                            GestureDetector(
                              onTap: () => setState(() => satellite = !satellite),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: satellite
                                      ? const Color(0xFFFF6B2B)
                                      : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  satellite ? Icons.map_rounded : Icons.satellite_alt_rounded,
                                  size: 16,
                                  color: satellite ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF334155)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Filter Capsules Bar
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            'All',
                            '⚡ Charging',
                            '🚻 Washrooms',
                            '🛗 Lifts',
                            '♿ Ramps',
                            '🏢 Hostels',
                            '🎓 Academic',
                            '☕ Food',
                          ].map((f) {
                            final isSel = _activeFilter == f;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: GestureDetector(
                                onTap: () => setState(() => _activeFilter = f),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: isSel
                                        ? const Color(0xFFFF6B2B)
                                        : (isDark
                                            ? const Color(0xFF131B2E).withValues(alpha: 0.8)
                                            : Colors.white.withValues(alpha: 0.9)),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSel ? const Color(0xFFFF6B2B) : (isDark ? Colors.white12 : Colors.black12),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    f,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                      color: isSel ? Colors.white : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---- Floating GPS & Quick Actions ----
              Positioned(
                right: 16,
                bottom: _selectedPlace != null ? 240 : 80,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Recenter on Campus Button
                    GestureDetector(
                      onTap: () => _centerOn(campusCenter),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF131B2E).withValues(alpha: 0.9) : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.school_rounded, size: 20, color: Color(0xFFFF6B2B)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // My GPS Location Button
                    GestureDetector(
                      onTap: () async {
                        await store.startWatch();
                        if (store.myPos != null) {
                          _centerOn(LatLng(store.myPos!.latitude, store.myPos!.longitude));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF131B2E).withValues(alpha: 0.9) : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.my_location_rounded, size: 20, color: Color(0xFF38BDF8)),
                      ),
                    ),
                  ],
                ),
              ),

              // ---- Floating Action Buttons (Add Spot & Live Vision Scanner) ----
              Positioned(
                left: 16,
                right: 16,
                bottom: _selectedPlace != null ? 240 : 80,
                child: Row(
                  children: [
                    GlassPillButton(
                      text: '+ Add Spot',
                      icon: Icons.add_location_alt_rounded,
                      color: const Color(0xFFFF6B2B),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddPlacePage(),
                        ),
                      ),
                    ),
                    const Spacer(),
                    GlassPillButton(
                      text: 'AI Vision & Buzzer',
                      icon: Icons.videocam_rounded,
                      color: const Color(0xFF00F0FF),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VisionDetectorPage(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ---- Selected Landmark Bottom Glassmorphic Preview Card ----
              if (_selectedPlace != null)
                Positioned(
                  bottom: 16,
                  left: 14,
                  right: 14,
                  child: GlassContainer(
                    borderRadius: 26,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Header
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _selectedPlace!.color.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: _selectedPlace!.color, width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  _selectedPlace!.reviews.isEmpty ? 'NEW' : '${_selectedPlace!.score}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: _selectedPlace!.color,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedPlace!.name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          _selectedPlace!.type,
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(_selectedPlace!.tierIcon, size: 12, color: _selectedPlace!.color),
                                      const SizedBox(width: 3),
                                      Text(
                                        _selectedPlace!.tierLabel,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: _selectedPlace!.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () => setState(() => _selectedPlace = null),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Facility Pills Row
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            // Washroom pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                '🚻 ${_selectedPlace!.totalAccessibleWashrooms} Accessible / ${_selectedPlace!.totalWashrooms} Toilets',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF38BDF8)),
                              ),
                            ),
                            // Lift pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (_selectedPlace!.hasLift ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: (_selectedPlace!.hasLift ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                _selectedPlace!.hasLift ? '🛗 Lifts: ${_selectedPlace!.totalLifts} Working' : '🛗 No Lift',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: _selectedPlace!.hasLift ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                ),
                              ),
                            ),
                            // Ramp pill
                            if (_selectedPlace!.hasRamp)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B2B).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFFF6B2B).withValues(alpha: 0.3)),
                                ),
                                child: const Text(
                                  '♿ Step-Free Ramp',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFFF6B2B)),
                                ),
                              ),
                          ],
                        ),

                        if (_selectedPlace!.adminNotice != null && _selectedPlace!.adminNotice!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded, color: Color(0xFFB45309), size: 14),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _selectedPlace!.adminNotice!,
                                    style: const TextStyle(fontSize: 10, color: Color(0xFF92400E)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 12),
                        // Action Buttons: Engage EV HUD + Detail Page
                        Row(
                          children: [
                            Expanded(
                              child: GlassPillButton(
                                text: '⚡ Navigate HUD',
                                icon: Icons.navigation_rounded,
                                color: const Color(0xFF00F0FF),
                                onPressed: () {
                                  setState(() => _isNavigating = true);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GlassPillButton(
                                text: 'Floor Intel ↗',
                                icon: Icons.layers_rounded,
                                color: const Color(0xFFFF6B2B),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetailPage(_selectedPlace!),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              // ---- EV Turn-by-Turn Route Guidance HUD Overlay ----
              if (_isNavigating && _selectedPlace != null)
                Positioned(
                  bottom: 16,
                  left: 14,
                  right: 14,
                  child: EvRouteGuidanceHud(
                    destinationName: _selectedPlace!.name,
                    distanceMeters: (store.distanceTo(_selectedPlace!) ?? 320).toDouble(),
                    etaMinutes: '${((store.distanceTo(_selectedPlace!) ?? 320) / 75).ceil().clamp(1, 15)} min',
                    nextManeuver: _selectedPlace!.isChargingStation
                        ? 'Dock at rapid charging bay • 220V Ground portico'
                        : (_selectedPlace!.hasRamp
                            ? 'Proceed via 1:12 step-free ramp entrance'
                            : 'Follow paved corridor to elevator foyer'),
                    batteryCostPercent: (((store.distanceTo(_selectedPlace!) ?? 320) / 400).ceil()).clamp(1, 4),
                    onCancel: () => setState(() => _isNavigating = false),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showHazardBottomSheet(BuildContext context, SafetyHazardBeacon hz, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0B132B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
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
                      color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Text(hz.icon, style: const TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hz.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Reported by ${hz.reportedBy} • ${hz.timeAgo}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                hz.description,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.campaign_rounded, size: 18),
                      label: const Text('TRIGGER BUZZER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      onPressed: () {
                        ThreatType t = ThreatType.strayDog;
                        if (hz.threatClass == 'monkey') t = ThreatType.monkey;
                        if (hz.threatClass == 'cattle') t = ThreatType.cattle;
                        if (hz.threatClass == 'snake') t = ThreatType.snake;
                        if (hz.threatClass == 'pothole') t = ThreatType.potholeObstacle;
                        VisionBuzzerService.instance.triggerEmergencyDeterrent(t);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Acoustic & Strobe Buzzer activated for ${hz.threatClass}!'),
                            backgroundColor: const Color(0xFFEF4444),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF00F0FF),
                        side: const BorderSide(color: Color(0xFF00F0FF)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.videocam_rounded, size: 18),
                      label: const Text('CAMERA HUD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      onPressed: () {
                        Navigator.pop(context);
                        ThreatType t = ThreatType.strayDog;
                        if (hz.threatClass == 'monkey') t = ThreatType.monkey;
                        if (hz.threatClass == 'cattle') t = ThreatType.cattle;
                        if (hz.threatClass == 'snake') t = ThreatType.snake;
                        if (hz.threatClass == 'pothole') t = ThreatType.potholeObstacle;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VisionDetectorPage(initialScenario: t),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.smart_toy_outlined, size: 16, color: Color(0xFF00F0FF)),
                  label: const Text(
                    'Ask AI Assistant Safe Pathway Guidance',
                    style: TextStyle(color: Color(0xFF00F0FF), fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AIChatPage(
                          initialQuery: 'How to bypass the ${hz.title} safely on my wheelchair or walk path?',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
