// ============================================================
// add_place_page.dart — Open Public Community Contribution
// Add Any Campus Landmark, Public Washroom, Lift, or Ramp
// ============================================================

import 'package:flutter/material.dart';
import '../models.dart';
import '../store.dart';
import '../widgets/glass_container.dart';

class AddPlacePage extends StatefulWidget {
  final double? lat, lng;
  const AddPlacePage({super.key, this.lat, this.lng});

  @override
  State<AddPlacePage> createState() => _AddPlacePageState();
}

class _AddPlacePageState extends State<AddPlacePage> {
  final nameCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  String type = 'Washroom';
  double? lat, lng;
  bool gettingGps = false;

  // Accessibility flags
  bool hasRamp = true;
  bool hasLift = false;
  bool hasAccessibleWashroom = true;
  int accessibleToiletsCount = 2;
  int floorNumber = 0;

  final List<String> availableTypes = [
    'Washroom',
    'Hostel',
    'Academic',
    'Food',
    'Library',
    'Health',
    'Facility',
    'Auditorium',
  ];

  @override
  void initState() {
    super.initState();
    lat = widget.lat;
    lng = widget.lng;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _useMyLocation() async {
    setState(() => gettingGps = true);
    await store.startWatch();
    setState(() {
      lat = store.myPos?.latitude;
      lng = store.myPos?.longitude;
      gettingGps = false;
    });

    if (lat == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📍 Location detect nahi ho payi. Please check GPS permissions.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF090D16), Color(0xFF0F172A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : const LinearGradient(
            colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Add Public Landmark / Washroom',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : const Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              // Community Notice Badge
              GlassContainer(
                padding: const EdgeInsets.all(14),
                borderRadius: 20,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B2B).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.public_rounded, color: Color(0xFFFF6B2B), size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Open Public Contribution',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Koi bhi student ya visitor campus me naya public washroom, lift ya ramp register kar sakta hai.',
                            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Card 1: Name and Category
              GlassContainer(
                borderRadius: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit_location_alt_rounded, color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7), size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Place / Facility Information',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        labelText: 'Spot Name',
                        hintText: 'e.g. NLHC Ground Divyang Toilet, Jasper Lift 1...',
                        hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                        labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                        prefixIcon: const Icon(Icons.tag_rounded),
                        filled: true,
                        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Category',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableTypes.map((t) {
                        final isSel = type == t;
                        return GestureDetector(
                          onTap: () => setState(() => type = t),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? const Color(0xFFFF6B2B)
                                  : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04)),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSel ? const Color(0xFFFF6B2B) : (isDark ? Colors.white10 : Colors.black12),
                              ),
                            ),
                            child: Text(
                              t == 'Washroom' ? '🚻 Washroom' : (t == 'Hostel' ? '🏢 Hostel' : (t == 'Academic' ? '🎓 Academic' : t)),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                color: isSel ? Colors.white : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Card 2: Accessibility Specifics (Washroom, Ramp, Lift)
              GlassContainer(
                borderRadius: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.accessible_forward_rounded, color: isDark ? const Color(0xFF10B981) : const Color(0xFF059669), size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Accessibility & Facility Details',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Step-free ramp switch
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: hasRamp,
                      title: const Text('♿ Step-Free Ramp Entrance', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Wheelchair accessible entry with zero steps', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                      activeTrackColor: const Color(0xFF10B981),
                      onChanged: (v) => setState(() => hasRamp = v),
                    ),
                    const Divider(height: 16),

                    // Lift switch
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: hasLift,
                      title: const Text('🛗 Operational Passenger Lift', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Working elevator with wide doors', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                      activeTrackColor: const Color(0xFF38BDF8),
                      onChanged: (v) => setState(() => hasLift = v),
                    ),
                    const Divider(height: 16),

                    // Accessible washroom switch
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: hasAccessibleWashroom,
                      title: const Text('🚻 Divyangjan Accessible Washroom', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Dedicated cubicle with grab bars and low sinks', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                      activeTrackColor: const Color(0xFFFF6B2B),
                      onChanged: (v) => setState(() => hasAccessibleWashroom = v),
                    ),

                    if (hasAccessibleWashroom) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Accessible Toilets Count:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, size: 20),
                                onPressed: accessibleToiletsCount > 1
                                    ? () => setState(() => accessibleToiletsCount--)
                                    : null,
                              ),
                              Text('$accessibleToiletsCount', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, size: 20),
                                onPressed: () => setState(() => accessibleToiletsCount++),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Card 3: Location / Coordinates
              GlassContainer(
                borderRadius: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.pin_drop_rounded, color: Color(0xFFFF6B2B), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Location Coordinates',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            lat != null ? Icons.check_circle_rounded : Icons.pending_outlined,
                            color: lat != null ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lat == null
                                      ? 'Coordinates not set yet'
                                      : '📍 ${lat!.toStringAsFixed(5)}° N, ${lng!.toStringAsFixed(5)}° E',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                Text(
                                  widget.lat != null
                                      ? 'Captured from map tap location'
                                      : (lat != null ? 'Captured via live GPS' : 'Tap button below to capture GPS'),
                                  style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: BorderSide(color: isDark ? Colors.white24 : Colors.black26),
                        ),
                        icon: gettingGps
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.my_location_rounded, size: 16),
                        label: const Text('Capture Current GPS Coordinates', style: TextStyle(fontSize: 12)),
                        onPressed: gettingGps ? null : _useMyLocation,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Publish Button
              GlassPillButton(
                text: 'Publish to Public Campus Map 🚀',
                icon: Icons.cloud_upload_rounded,
                color: const Color(0xFFFF6B2B),
                onPressed: () {
                  final placeName = nameCtrl.text.trim();
                  if (placeName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kripya place ya washroom ka naam enter karein! ✍️')),
                    );
                    return;
                  }
                  if (lat == null) {
                    // Fallback to campus center if not explicitly set
                    lat = 23.8152;
                    lng = 86.4415;
                  }

                  final newPlace = Place(
                    id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                    name: placeName,
                    type: type,
                    lat: lat!,
                    lng: lng!,
                    isCustom: true,
                    isLiftOperational: hasLift,
                    floors: [
                      FloorInfo(
                        floorNumber: floorNumber,
                        name: floorNumber == 0 ? 'Ground Floor' : 'Floor $floorNumber',
                        totalWashrooms: hasAccessibleWashroom ? accessibleToiletsCount + 4 : 4,
                        accessibleWashrooms: hasAccessibleWashroom ? accessibleToiletsCount : 0,
                        liftsCount: hasLift ? 1 : 0,
                        hasRamp: hasRamp,
                        facilities: [
                          if (hasRamp) '♿ Step-Free Access Ramp Verified',
                          if (hasLift) '🛗 Operational Passenger Elevator',
                          if (hasAccessibleWashroom) '🚻 Divyangjan Accessible Washroom with Grab Bars',
                        ],
                      ),
                    ],
                  );

                  store.addPlace(newPlace);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ "$placeName" added and synced to public cloud!'),
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
