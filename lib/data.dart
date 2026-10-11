// ============================================================
// data.dart — IIT (ISM) Dhanbad Campus Verified Landmark Data
// Every venue detailed with Lifts, Accessible Washrooms, Seating & Wayfinding
// ============================================================

import 'models.dart';

List<Place> seedPlaces() => [
      // ------------------------------------------------------------
      // 🏢 1. HERAKLES (HERAK) HOSTEL
      // 5 Floors, 2 Working Lifts, 10 Washrooms/Floor (2 Accessible)
      // ------------------------------------------------------------
      Place(
        id: 'herak',
        name: 'Herakles (Herak) Hostel',
        type: 'Hostel',
        lat: 23.8162,
        lng: 86.4428,
        isLiftOperational: true,
        floors: [
          const FloorInfo(
            floorNumber: 0,
            name: 'Ground Floor',
            totalWashrooms: 10,
            accessibleWashrooms: 2,
            liftsCount: 2,
            hasRamp: true,
            facilities: [
              '🛗 Step-Free: 1:12 Gradient Entry Ramp with Dual Stainless Handrails',
              '⬆️ Lifts: 2 Working Otis Elevators with Braille Buttons & Audio Beeps',
              '🚻 Washrooms: 10 Total (2 Dedicated Divyang/Wheelchair Units with Grab Bars)',
              '💺 Seating: Mess Dining Priority Seating & Visitor Lounge Benches',
              '🧭 Wayfinding: High-Contrast Tactile Ground Paving from Gate to Elevator',
            ],
          ),
          const FloorInfo(
            floorNumber: 1,
            name: '1st Floor',
            totalWashrooms: 10,
            accessibleWashrooms: 2,
            liftsCount: 2,
            hasRamp: false,
            facilities: [
              '⬆️ Lifts: 2 Working Lifts with 90cm Wide Doors',
              '🚻 Washrooms: 10 Total (2 Wheelchair Restrooms with Low Sinks & Anti-Slip Tiles)',
              '💺 Seating: Quiet Study Room with Ergonomic Chairs',
              '🧭 Wayfinding: Embossed Braille Wing Indicators & Exit Signs',
            ],
          ),
          const FloorInfo(
            floorNumber: 2,
            name: '2nd Floor',
            totalWashrooms: 10,
            accessibleWashrooms: 2,
            liftsCount: 2,
            hasRamp: false,
            facilities: [
              '⬆️ Lifts: 2 Working Elevators',
              '🚻 Washrooms: 10 Total (2 Accessible Washrooms with Emergency Pull Cords)',
              '💺 Seating: Common Room Sofa Seating',
              '🧭 Wayfinding: Large High-Contrast Directional Signage',
            ],
          ),
          const FloorInfo(
            floorNumber: 3,
            name: '3rd Floor',
            totalWashrooms: 10,
            accessibleWashrooms: 2,
            liftsCount: 2,
            hasRamp: false,
            facilities: [
              '⬆️ Lifts: 2 Working Elevators',
              '🚻 Washrooms: 10 Total (2 Accessible Restrooms with Outward Opening Doors)',
              '💺 Seating: Corridor Rest Benches',
              '🧭 Wayfinding: Corridor Floor Map & Room Directories',
            ],
          ),
          const FloorInfo(
            floorNumber: 4,
            name: '4th Floor',
            totalWashrooms: 10,
            accessibleWashrooms: 2,
            liftsCount: 2,
            hasRamp: false,
            facilities: [
              '⬆️ Lifts: 2 Working Elevators',
              '🚻 Washrooms: 10 Total (2 Accessible Restrooms with Support Handrails)',
              '💺 Seating: Terrace Lounge Seating',
              '🧭 Wayfinding: Emergency Evacuation Braille Map',
            ],
          ),
        ],
        reviews: [
          Review(
            scores: [5, 5, 5, 4, 5],
            user: 'Aman Sharma',
            userRole: 'Student (Wheelchair User)',
            comment:
                'Herak Hostel is the gold standard on campus! Ground ramp is very smooth, 2 elevators work reliably, and every floor has 2 accessible washrooms with solid grab bars.',
            photoPath: 'assets/reviews/herak_ramp.jpeg',
            targetTag: '🛗 Ground Entrance Ramp',
            targetFloor: 0,
            upvotes: 18,
          ),
          Review(
            scores: [5, 5, 4, 4, 4],
            user: 'Priya Patel',
            userRole: 'Student (Visual Assist)',
            comment:
                'Tactile floor paving leads right to the elevators. Braille elevator buttons make independent navigation effortless.',
            photoPath: 'assets/reviews/herak_lift.jpeg',
            targetTag: '⬆️ Otis Passenger Lifts',
            targetFloor: 1,
            upvotes: 12,
          ),
          Review(
            scores: [5, 5, 5, 5, 5],
            user: 'Campus Admin',
            userRole: 'Admin',
            comment:
                'Estate Office Verified: 5 floors inspected. 2 Lifts operational. 10 washrooms per floor maintained daily (2 accessible with grab bars).',
            photoPath: 'assets/reviews/herak_washroom.jpeg',
            targetTag: '🚻 Divyang Washroom (2nd Floor)',
            targetFloor: 2,
            upvotes: 27,
          ),
        ],
      ),

      // ------------------------------------------------------------
      // 🏢 2. JASPER HOSTEL
      // 5 Floors, 2 Lifts, 10 Washrooms/Floor (2 Accessible)
      // ------------------------------------------------------------
      Place(
        id: 'jasper',
        name: 'Jasper Hostel',
        type: 'Hostel',
        lat: 23.8170,
        lng: 86.4435,
        floors: List.generate(5, (i) => FloorInfo(
          floorNumber: i,
          name: i == 0 ? 'Ground Floor' : 'Floor $i',
          totalWashrooms: 10,
          accessibleWashrooms: 2,
          liftsCount: 2,
          hasRamp: i == 0,
          facilities: [
            if (i == 0) '🛗 Step-Free: Concrete Entrance Ramp',
            '⬆️ Lifts: 2 High-Speed Elevators',
            '🚻 Washrooms: 10 Total (2 Accessible Divyang Units with Grab Rails)',
            '💺 Seating: Ground Mess Waiting Area & Student Lounge',
            '🧭 Wayfinding: Directional Floor Maps & Signage',
          ],
        )),
        reviews: [
          Review(
            scores: [5, 5, 4, 4, 4],
            user: 'Vikas Singh',
            comment: '5 floors with 2 lifts that are always running. 10 washrooms per floor with 2 accessible ones.',
            photoPath: 'assets/reviews/accessible_toilet.jpeg',
          ),
        ],
      ),

      // ------------------------------------------------------------
      // 🏢 3. AMBER HOSTEL
      // 5 Floors, 2 Lifts, 10 Washrooms/Floor (2 Accessible)
      // ------------------------------------------------------------
      Place(
        id: 'amber',
        name: 'Amber Hostel',
        type: 'Hostel',
        lat: 23.8158,
        lng: 86.4440,
        floors: List.generate(5, (i) => FloorInfo(
          floorNumber: i,
          name: i == 0 ? 'Ground Floor' : 'Floor $i',
          totalWashrooms: 10,
          accessibleWashrooms: 2,
          liftsCount: 2,
          hasRamp: i == 0,
          facilities: [
            if (i == 0) '🛗 Step-Free: Front Porch Ramp with Non-Slip Coating',
            '⬆️ Lifts: 2 Otis Elevators',
            '🚻 Washrooms: 10 Total (2 Wheelchair Accessible)',
            '💺 Seating: Reading Room Seating & Dining Area',
            '🧭 Wayfinding: Tactile Corridor Markers',
          ],
        )),
        reviews: [
          Review(
            scores: [4, 4, 4, 4, 4],
            user: 'Rahul',
            comment: 'Ramp entry is well placed. Lifts and washrooms are clean.',
            photoPath: 'assets/reviews/hostel_corridor.jpeg',
          ),
        ],
      ),

      // ------------------------------------------------------------
      // 🏢 4. DIAMOND HOSTEL
      // 5 Floors, 2 Lifts, 10 Washrooms/Floor (2 Accessible)
      // ------------------------------------------------------------
      Place(
        id: 'diamond',
        name: 'Diamond Hostel',
        type: 'Hostel',
        lat: 23.8166,
        lng: 86.4418,
        floors: List.generate(5, (i) => FloorInfo(
          floorNumber: i,
          name: i == 0 ? 'Ground Floor' : 'Floor $i',
          totalWashrooms: 10,
          accessibleWashrooms: 2,
          liftsCount: 2,
          hasRamp: i == 0,
          facilities: [
            if (i == 0) '🛗 Step-Free: Ramp Connected to Main Quadrangle',
            '⬆️ Lifts: 2 Working Elevators',
            '🚻 Washrooms: 10 Total (2 Accessible)',
            '💺 Seating: Common Room TV Lounge Seating',
            '🧭 Wayfinding: Prominent Block Direction Signs',
          ],
        )),
        reviews: [
          Review(
            scores: [4, 4, 4, 3, 4],
            user: 'Aman',
            comment: 'Good infrastructure, step-free access to mess and lifts.',
            photoPath: 'assets/reviews/herak_hostel.jpeg',
          ),
        ],
      ),

      // ------------------------------------------------------------
      // 📚 5. CENTRAL LIBRARY
      // 4 Floors, 2 Lifts, 8 Washrooms/Floor (2 Accessible)
      // ------------------------------------------------------------
      Place(
        id: 'library',
        name: 'Central Library',
        type: 'Library',
        lat: 23.8152,
        lng: 86.4403,
        floors: List.generate(4, (i) => FloorInfo(
          floorNumber: i,
          name: i == 0 ? 'Ground Floor' : 'Floor $i',
          totalWashrooms: 8,
          accessibleWashrooms: 2,
          liftsCount: 2,
          hasRamp: i == 0,
          facilities: [
            if (i == 0) '🛗 Step-Free: Automated Glass Sliding Doors with Zero Threshold',
            '⬆️ Lifts: 2 Glass Observation Elevators (Braille + Audio Alerts)',
            '🚻 Washrooms: 8 Total (2 Fully Compliant Accessible Washrooms with Support Bars)',
            '💺 Seating: Ergonomic Accessible Reading Pods & Wheelchair-Height Desks',
            '🧭 Wayfinding: Tactile Guide Paths, Large Print Book Stacks & Braille Catalog Terminals',
          ],
        )),
        reviews: [
          Review(
            scores: [5, 5, 5, 5, 5],
            user: 'Sneha Roy',
            comment: 'Fully accessible academic paradise! Zero barrier entry, 2 modern lifts, accessible restrooms on every level.',
            photoPath: 'assets/reviews/herak_lift.jpeg',
          ),
        ],
      ),

      // ------------------------------------------------------------
      // 🏛️ 6. MAIN BUILDING (HERITAGE)
      // 3 Floors, 1 Lift, 6 Washrooms/Floor (2 Accessible)
      // ------------------------------------------------------------
      Place(
        id: 'main',
        name: 'Main Building (Heritage)',
        type: 'Academic',
        lat: 23.8146,
        lng: 86.4412,
        floors: List.generate(3, (i) => FloorInfo(
          floorNumber: i,
          name: i == 0 ? 'Ground Floor' : 'Floor $i',
          totalWashrooms: 6,
          accessibleWashrooms: 2,
          liftsCount: 1,
          hasRamp: i == 0,
          facilities: [
            if (i == 0) '🛗 Step-Free: Grand Heritage Portico Entry Ramp',
            '⬆️ Lifts: 1 Passenger Elevator Serving Administrative Wings',
            '🚻 Washrooms: 6 Total (2 Accessible Restrooms with Wide Entry)',
            '💺 Seating: Administrative Waiting Lounges with Armchairs',
            '🧭 Wayfinding: Bilingual Directional Plaques & Building Floor Plans',
          ],
        )),
        reviews: [
          Review(
            scores: [4, 4, 4, 4, 4],
            user: 'Dr. Sen',
            comment: 'Heritage architecture with retrofit elevator and portico ramp.',
            photoPath: 'assets/reviews/herak_ramp.jpeg',
          ),
        ],
      ),

      // ------------------------------------------------------------
      // 🏫 7. NEW LECTURE HALL COMPLEX (NLHC)
      // 3 Floors, 2 Lifts, 8 Washrooms/Floor (2 Accessible)
      // ------------------------------------------------------------
      Place(
        id: 'nlhc',
        name: 'New Lecture Hall Complex (NLHC)',
        type: 'Academic',
        lat: 23.8148,
        lng: 86.4390,
        floors: List.generate(3, (i) => FloorInfo(
          floorNumber: i,
          name: i == 0 ? 'Ground Floor' : 'Floor $i',
          totalWashrooms: 8,
          accessibleWashrooms: 2,
          liftsCount: 2,
          hasRamp: i == 0,
          facilities: [
            if (i == 0) '🛗 Step-Free: Gentle Ramp to Amphitheater Lecture Theatres',
            '⬆️ Lifts: 2 Heavy-Duty Passenger Lifts with Voice Announcement',
            '🚻 Washrooms: 8 Total (2 Dedicated Divyang Restrooms with Panic Alarm)',
            '💺 Seating: Tiered Halls with Front Row Wheelchair Stations',
            '🧭 Wayfinding: LED Digital Wayfinding & Tactile Threshold Plates',
          ],
        )),
        reviews: [
          Review(
            scores: [5, 5, 5, 5, 5],
            user: 'Aman',
            comment: 'World-class lecture complex. Elevators are fast, wheelchair spots have charging points.',
            photoPath: 'assets/reviews/accessible_toilet.jpeg',
          ),
        ],
      ),

      // ------------------------------------------------------------
      // 🏥 8. CAMPUS HEALTH CENTRE
      // 2 Floors, 1 Stretcher Lift, 6 Washrooms/Floor (2 Accessible)
      // ------------------------------------------------------------
      Place(
        id: 'health',
        name: 'Campus Health Centre',
        type: 'Health',
        lat: 23.8129,
        lng: 86.4395,
        floors: List.generate(2, (i) => FloorInfo(
          floorNumber: i,
          name: i == 0 ? 'Ground Floor' : 'Floor $i',
          totalWashrooms: 6,
          accessibleWashrooms: 2,
          liftsCount: 1,
          hasRamp: true,
          facilities: [
            '🛗 Step-Free: 24x7 Emergency Ambulance Bay & Wide Wheelchair Ramps',
            '⬆️ Lifts: 1 Bed & Stretcher Compatible Medical Elevator',
            '🚻 Washrooms: 6 Total (2 Barrier-Free Washrooms with Emergency Pull Strings)',
            '💺 Seating: OPD Waiting Benches with Wheelchair Transfer Spaces',
            '🧭 Wayfinding: High-Contrast Illuminated Emergency Wayfinding',
          ],
        )),
        reviews: [
          Review(
            scores: [5, 5, 5, 5, 5],
            user: 'Dr. Sen',
            userRole: 'Admin',
            comment: '100% barrier-free medical center. Stretchers and wheelchairs always available.',
            photoPath: 'assets/reviews/herak_washroom.jpeg',
          ),
        ],
      ),

      // ------------------------------------------------------------
      // 🎭 9. PENMAN AUDITORIUM
      // 2 Floors, 1 Lift, 6 Washrooms/Floor (2 Accessible)
      // ------------------------------------------------------------
      Place(
        id: 'penman',
        name: 'Penman Auditorium',
        type: 'Auditorium',
        lat: 23.8140,
        lng: 86.4420,
        floors: [
          const FloorInfo(
            floorNumber: 0,
            name: 'Auditorium Ground',
            totalWashrooms: 6,
            accessibleWashrooms: 2,
            liftsCount: 1,
            hasRamp: true,
            facilities: [
              '🛗 Step-Free: Stage Access Ramp & Foyer Ramp',
              '⬆️ Lifts: 1 Stage & Balcony Access Elevator',
              '🚻 Washrooms: 6 Total (2 Wheelchair Accessible)',
              '💺 Seating: Designated Front-Row Wheelchair Stations with Companions',
              '🧭 Wayfinding: Illuminated Aisle Markers & Tactile Braille Signage',
            ],
          ),
          const FloorInfo(
            floorNumber: 1,
            name: 'Balcony & Control',
            totalWashrooms: 4,
            accessibleWashrooms: 1,
            liftsCount: 1,
            facilities: [
              '⬆️ Lifts: Elevator Landing',
              '🚻 Washrooms: 4 Total (1 Accessible)',
              '💺 Seating: Balcony Seating',
            ],
          ),
        ],
        reviews: [
          Review(scores: [4, 4, 4, 5, 4], user: 'Sneha', comment: 'Wheelchair access to the main hall and stage ramp makes convocations inclusive.'),
        ],
      ),

      // ------------------------------------------------------------
      // 🏟️ 10. STUDENT ACTIVITY CENTRE (SAC)
      // 2 Floors, 1 Lift, 6 Washrooms/Floor (2 Accessible)
      // ------------------------------------------------------------
      Place(
        id: 'sac',
        name: 'Student Activity Centre (SAC)',
        type: 'Recreation',
        lat: 23.8135,
        lng: 86.4430,
        floors: [
          const FloorInfo(
            floorNumber: 0,
            name: 'Ground Floor',
            totalWashrooms: 6,
            accessibleWashrooms: 2,
            liftsCount: 1,
            hasRamp: true,
            facilities: [
              '🛗 Step-Free: Ground Floor Ramp Access to Indoor Courts & Clubs',
              '⬆️ Lifts: 1 Elevator Connecting Ground and 1st Floor',
              '🚻 Washrooms: 6 Total (2 Accessible Showers & Washrooms)',
              '💺 Seating: Spectator Benches & Club Meeting Seating',
              '🧭 Wayfinding: Club Room Directories & Activity Maps',
            ],
          ),
          const FloorInfo(
            floorNumber: 1,
            name: '1st Floor',
            totalWashrooms: 6,
            accessibleWashrooms: 1,
            liftsCount: 1,
            facilities: [
              '⬆️ Lifts: Elevator Access',
              '🚻 Washrooms: 6 Total (1 Accessible)',
              '💺 Seating: Music & Arts Room Seating',
            ],
          ),
        ],
        reviews: [
          Review(scores: [4, 4, 4, 4, 4], user: 'Vikas', comment: 'Ground floor courts and club rooms are step-free. Elevator works fine.'),
        ],
      ),
    ];
