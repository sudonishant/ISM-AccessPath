import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accesspath/main.dart';
import 'package:accesspath/store.dart';
import 'package:accesspath/pages/detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    // Initialize seed data for tests
    await store.load();
  });

  testWidgets('AccessPath app smoke & accessibility features test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Build AccessPath application
    await tester.pumpWidget(const AccessPathApp());
    await tester.pumpAndSettle();

    // 1. Verify App Header
    expect(find.text('AccessPath'), findsOneWidget);
    expect(find.textContaining('IIT (ISM) Dhanbad'), findsWidgets);

    // 2. Verify Bottom Navigation destinations
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Map'), findsOneWidget);
    expect(find.text('Add Place'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // 3. Verify EV Cockpit Telemetry & Charging Station Beacon
    expect(find.textContaining('BATTERY'), findsWidgets);
    expect(find.textContaining('KM'), findsWidgets);
    expect(find.textContaining('EV Charging'), findsWidgets);

    // 4. Verify Filter by Needs chips
    expect(find.textContaining('Step-free Access'), findsWidgets);
    expect(find.textContaining('Lift'), findsWidgets);
    expect(find.textContaining('Washroom'), findsWidgets);

    // 5. Verify seed places & charging ports are displayed
    expect(find.textContaining('Herakles'), findsWidgets);
    expect(find.textContaining('Jasper'), findsWidgets);
    expect(find.textContaining('NLHC Rapid Mobility'), findsWidgets);

    // 6. Verify direct rendering of DetailPage for Herakles Hostel

    final herak = store.places.firstWhere((p) => p.id == 'herak');
    await tester.pumpWidget(
      MaterialApp(
        home: DetailPage(herak),
      ),
    );
    await tester.pumpAndSettle();

    // 6. Verify 5 Structured Rating dimensions on DetailPage
    expect(find.text('Campus Accessibility Metrics'), findsOneWidget);
    expect(find.textContaining('Step-free Access'), findsWidgets);
    expect(find.textContaining('Lift'), findsWidgets);
    expect(find.textContaining('Washroom'), findsWidgets);
    expect(find.textContaining('Seating'), findsWidgets);
    expect(find.textContaining('Wayfinding'), findsWidgets);

    // 7. Verify AI Community Summary card
    expect(find.text('AI Campus Summary'), findsOneWidget);

    // 8. Verify Floor-by-Floor Architecture Inspector & Levels badge
    expect(find.text('Floor-by-Floor Architecture'), findsOneWidget);
    expect(find.textContaining('5 Levels'), findsOneWidget);
  });
}
