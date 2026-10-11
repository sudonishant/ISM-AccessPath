// ============================================================
// map_page.dart — Exclusively IIT (ISM) Dhanbad Campus Map
// OpenStreetMap + Satellite Mode focused on Campus Landmarks
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models.dart';
import '../store.dart';
import 'add_place_page.dart';
import 'detail_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool satellite = false;
  final mapCtrl = MapController();
  Place? _selectedPlace;
  String _selectedCategory = 'All';

  // IIT (ISM) Dhanbad Campus Coordinates
  static const campusCenter = LatLng(23.8152, 86.4415);
  static const osmUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const satUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final campusPlaces = store.places.where((p) {
          if (_selectedCategory == 'All') return true;
          return p.type.toLowerCase() == _selectedCategory.toLowerCase();
        }).toList();

        return Scaffold(
          body: Stack(
            children: [
              // ---- Campus OpenStreetMap / Satellite Layer ----
              FlutterMap(
                mapController: mapCtrl,
                options: MapOptions(
                  initialCenter: campusCenter,
                  initialZoom: 16.0,
                  minZoom: 14.5,
                  maxZoom: 18.5,
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

                  // ---- Campus Markers Layer ----
                  MarkerLayer(
                    markers: [
                      ...campusPlaces.map((p) {
                        final isSelected = _selectedPlace?.id == p.id;
                        final isHerak = p.id == 'herak';

                        return Marker(
                          point: LatLng(p.lat, p.lng),
                          width: isHerak ? 64 : 54,
                          height: isHerak ? 64 : 54,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPlace = p),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: p.color, width: isHerak ? 2 : 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    isHerak ? '🏢 HERAK' : (p.reviews.isEmpty ? 'NEW' : '${p.score}'),
                                    style: TextStyle(
                                      fontSize: isHerak ? 8 : 9,
                                      fontWeight: FontWeight.w800,
                                      color: p.color,
                                    ),
                                  ),
                                ),
                                Icon(
                                  isHerak ? Icons.domain_rounded : Icons.location_on_rounded,
                                  color: p.color,
                                  size: isSelected ? 36 : (isHerak ? 32 : 28),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      // Live User Location Marker
                      if (store.myPos != null)
                        Marker(
                          point: LatLng(store.myPos!.latitude, store.myPos!.longitude),
                          width: 26,
                          height: 26,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F766E),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F766E).withValues(alpha: 0.4),
                                  blurRadius: 8,
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

              // ---- Top Campus Filter Bar ----
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.96),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.school_rounded, size: 18, color: Color(0xFF0F766E)),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'IIT (ISM) Dhanbad Campus Map',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                            ),
                            Text(
                              '${campusPlaces.length} Landmarks',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Campus Category Selector Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['All', 'Hostel', 'Academic', 'Library', 'Health', 'Auditorium'].map((cat) {
                            final isSel = _selectedCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text(cat),
                                selected: isSel,
                                selectedColor: const Color(0xFF0F766E),
                                labelStyle: TextStyle(
                                  fontSize: 11,
                                  color: isSel ? Colors.white : const Color(0xFF334155),
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                ),
                                onSelected: (val) {
                                  if (val) setState(() => _selectedCategory = cat);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---- Selected Place Bottom Preview Card ----
              if (_selectedPlace != null)
                Positioned(
                  bottom: 24,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _selectedPlace!.color.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: _selectedPlace!.color, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  _selectedPlace!.reviews.isEmpty ? 'NEW' : '${_selectedPlace!.score}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _selectedPlace!.color,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _selectedPlace!.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_selectedPlace!.type} • 🏢 ${_selectedPlace!.floorCount} Floors (2 Lifts)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedPlace!.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF0F766E),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => DetailPage(_selectedPlace!)),
                                );
                              },
                              child: const Text('Floors ➜', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              // ---- Map Control FABs ----
              Positioned(
                right: 16,
                bottom: _selectedPlace != null ? 120 : 24,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'satBtn',
                      tooltip: 'Toggle Satellite Layer',
                      backgroundColor: satellite ? const Color(0xFF0F766E) : Colors.white,
                      onPressed: () => setState(() => satellite = !satellite),
                      child: Icon(
                        Icons.satellite_alt_rounded,
                        color: satellite ? Colors.white : const Color(0xFF0F766E),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FloatingActionButton.small(
                      heroTag: 'campusCenterBtn',
                      tooltip: 'Center on IIT (ISM) Campus',
                      backgroundColor: Colors.white,
                      onPressed: () {
                        mapCtrl.move(campusCenter, 16.0);
                      },
                      child: const Icon(Icons.school_outlined, color: Color(0xFF0F766E)),
                    ),
                    const SizedBox(height: 10),
                    FloatingActionButton.small(
                      heroTag: 'locBtn',
                      tooltip: 'My Real-Time GPS Location',
                      backgroundColor: Colors.white,
                      onPressed: () async {
                        await store.startWatch();
                        if (store.myPos != null) {
                          mapCtrl.move(
                            LatLng(store.myPos!.latitude, store.myPos!.longitude),
                            16.5,
                          );
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('GPS signal unavailable. Enable location services.')),
                            );
                          }
                        }
                      },
                      child: const Icon(Icons.my_location_rounded, color: Color(0xFF0F766E)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
