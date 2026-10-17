import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bicycle_maintenance_log/main.dart';
import 'package:bicycle_maintenance_log/models/bicycle.dart';
import 'package:bicycle_maintenance_log/models/maintenance.dart';
import 'package:bicycle_maintenance_log/services/storage_service.dart';
import 'package:bicycle_maintenance_log/widgets/app_logo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Model Tests', () {
    test('Bicycle model toJson and fromJson work accurately', () {
      final now = DateTime(2024, 5, 10);
      final bicycle = Bicycle(
        id: 'bike-101',
        name: 'Road Runner',
        brand: 'Trek',
        model: 'Domane AL 2',
        purchaseDate: now,
      );

      final jsonMap = bicycle.toJson();
      final fromJson = Bicycle.fromJson(jsonMap);

      expect(fromJson.id, 'bike-101');
      expect(fromJson.name, 'Road Runner');
      expect(fromJson.brand, 'Trek');
      expect(fromJson.model, 'Domane AL 2');
      expect(fromJson.purchaseDate, now);
    });

    test('MaintenanceRecord model toJson and fromJson work accurately', () {
      final recordDate = DateTime(2024, 6, 1);
      final nextDate = DateTime(2024, 9, 1);
      final record = MaintenanceRecord(
        id: 'rec-202',
        bicycleId: 'bike-101',
        maintenanceType: 'Chain Lubrication',
        date: recordDate,
        cost: 25.50,
        notes: 'Cleaned chain and applied dry lube',
        nextServiceDate: nextDate,
      );

      final jsonMap = record.toJson();
      final fromJson = MaintenanceRecord.fromJson(jsonMap);

      expect(fromJson.id, 'rec-202');
      expect(fromJson.bicycleId, 'bike-101');
      expect(fromJson.maintenanceType, 'Chain Lubrication');
      expect(fromJson.cost, 25.50);
      expect(fromJson.date, recordDate);
      expect(fromJson.nextServiceDate, nextDate);
    });

    test(
        'MaintenanceRecord fromJson handles missing or malformed nextServiceDate safely',
        () {
      final jsonNoNext = {
        'id': 'rec-1',
        'bicycleId': 'bike-1',
        'maintenanceType': 'Brake Check',
        'date': '2026-10-17T00:00:00.000',
        'cost': 15.0,
        'notes': 'All good',
      };
      final parsed1 = MaintenanceRecord.fromJson(jsonNoNext);
      expect(parsed1.nextServiceDate, isNull);

      final jsonEmptyNext = {
        'id': 'rec-2',
        'bicycleId': 'bike-1',
        'maintenanceType': 'Brake Check',
        'date': '2026-10-17T00:00:00.000',
        'cost': 15.0,
        'notes': 'All good',
        'nextServiceDate': '',
      };
      final parsed2 = MaintenanceRecord.fromJson(jsonEmptyNext);
      expect(parsed2.nextServiceDate, isNull);

      final jsonInvalidNext = {
        'id': 'rec-3',
        'bicycleId': 'bike-1',
        'maintenanceType': 'Brake Check',
        'date': '2026-10-17T00:00:00.000',
        'cost': 15.0,
        'notes': 'All good',
        'nextServiceDate': 'invalid-date-string',
      };
      final parsed3 = MaintenanceRecord.fromJson(jsonInvalidNext);
      expect(parsed3.nextServiceDate, isNull);
    });
  });

  group('StorageService CRUD & Cascade Tests', () {
    test('Add, update, get, and delete bicycle with cascade deletion',
        () async {
      final bike = Bicycle(
        id: 'b1',
        name: 'City Commuter',
        brand: 'Giant',
        model: 'Escape 3',
        purchaseDate: DateTime(2023, 1, 1),
      );

      // Add bicycle
      await StorageService.addBicycle(bike);
      var bicycles = await StorageService.getBicycles();
      expect(bicycles.length, 1);
      expect(bicycles.first.name, 'City Commuter');

      // Add 2 maintenance records for this bicycle and 1 for another
      await StorageService.addMaintenanceRecord(MaintenanceRecord(
        id: 'm1',
        bicycleId: 'b1',
        maintenanceType: 'Brake Adjustment',
        date: DateTime.now(),
        cost: 15.0,
        notes: 'Tightened cables',
      ));
      await StorageService.addMaintenanceRecord(MaintenanceRecord(
        id: 'm2',
        bicycleId: 'b1',
        maintenanceType: 'Cleaning',
        date: DateTime.now(),
        cost: 10.0,
        notes: 'Wash & polish',
      ));
      await StorageService.addMaintenanceRecord(MaintenanceRecord(
        id: 'm3',
        bicycleId: 'other-bike',
        maintenanceType: 'Tyre Replacement',
        date: DateTime.now(),
        cost: 40.0,
        notes: 'New puncture resistant tyre',
      ));

      var records = await StorageService.getMaintenanceRecords();
      expect(records.length, 3);

      final totalExpense = await StorageService.getTotalExpenses();
      expect(totalExpense, 65.0);

      // Delete bicycle b1 - must cascade delete m1 & m2, keeping m3
      await StorageService.deleteBicycle('b1');

      bicycles = await StorageService.getBicycles();
      expect(bicycles.length, 0);

      records = await StorageService.getMaintenanceRecords();
      expect(records.length, 1);
      expect(records.first.id, 'm3');
    });
  });

  group('Widget & Hero Smoke Tests', () {
    testWidgets(
        'App launches with title, bottom navigation tabs, and SDG 11 section without hero collisions',
        (WidgetTester tester) async {
      await tester.pumpWidget(const BicycleMaintenanceApp());
      await tester.pumpAndSettle();

      // Check app title, logo, and professional subtitle
      expect(find.text('Bicycle Maintenance Log'), findsAtLeastNWidgets(1));
      expect(find.text('Ride Smart. Maintain Better.'), findsOneWidget);
      expect(find.byType(AppLogo), findsAtLeastNWidgets(1));

      // Ensure student roll number is not in the visible UI
      expect(find.textContaining('24PA1A05I0'), findsNothing);

      // Check SDG 11 card
      expect(find.textContaining('Supporting SDG 11'), findsOneWidget);

      // Check 4 bottom navigation tabs in BottomNavigationBar
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Bicycles'), findsAtLeastNWidgets(1));
      expect(find.text('History'), findsAtLeastNWidgets(1));
      expect(find.text('Reminders'), findsOneWidget);

      // Check FloatingActionButtons in IndexedStack have unique hero tags
      final fabs = tester
          .widgetList<FloatingActionButton>(find.byType(FloatingActionButton));
      final heroTags = fabs.map((f) => f.heroTag).toSet();
      expect(heroTags.length, equals(fabs.length),
          reason:
              'FloatingActionButtons in same subtree must have distinct hero tags');
    });
  });

  group('Scenario Functional Test: Reminders & Dashboard Lifecycle', () {
    testWidgets(
        'Full flow: Add Road bike, 17/29 Oct 2026 service, persist, edit, delete',
        (WidgetTester tester) async {
      // 1. Add bicycle named "Road"
      final roadBike = Bicycle(
        id: 'bike-road',
        name: 'Road',
        brand: 'Specialized',
        model: 'Allez',
        purchaseDate: DateTime(2026, 1, 1),
      );
      await StorageService.addBicycle(roadBike);

      // 2. Add maintenance record: Maintenance Date: 17 Oct 2026, Next Service: 29 Oct 2026
      final record = MaintenanceRecord(
        id: 'm-road-1',
        bicycleId: roadBike.id,
        maintenanceType: 'Chain Lubrication',
        date: DateTime(2026, 10, 17),
        cost: 150.0,
        notes: 'Applied ceramic lube',
        nextServiceDate: DateTime(2026, 10, 29),
      );
      await StorageService.addMaintenanceRecord(record);

      // Launch application
      await tester.pumpWidget(const BicycleMaintenanceApp());
      await tester.pumpAndSettle();

      // 6. Verify the Home Dashboard shows the upcoming service
      expect(find.text('Chain Lubrication'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Road'), findsAtLeastNWidgets(1));
      expect(find.textContaining('29 Oct 2026'), findsAtLeastNWidgets(1));
      expect(find.text('Upcoming'), findsAtLeastNWidgets(1));

      // 7. Verify the Reminders tab shows the same service
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();

      expect(find.text('Chain Lubrication'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Road'), findsAtLeastNWidgets(1));
      expect(find.textContaining('29 Oct 2026'), findsAtLeastNWidgets(1));
      expect(find.text('Upcoming'), findsAtLeastNWidgets(1));

      // 8. Close and reopen the application (pump new instance)
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      await tester.pumpWidget(const BicycleMaintenanceApp());
      await tester.pumpAndSettle();

      // 9. Verify the reminder is still saved
      expect(find.text('Chain Lubrication'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Road'), findsAtLeastNWidgets(1));
      expect(find.textContaining('29 Oct 2026'), findsAtLeastNWidgets(1));

      // 10. Edit the next service date and verify both screens update
      final updatedRecord = record.copyWith(
        nextServiceDate: DateTime(2026, 11, 15),
      );
      await StorageService.updateMaintenanceRecord(updatedRecord);

      // Switch to Reminders tab to trigger fresh data
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();
      expect(find.textContaining('15 Nov 2026'), findsAtLeastNWidgets(1));

      // Switch back to Home tab to verify update
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.textContaining('15 Nov 2026'), findsAtLeastNWidgets(1));

      // 11. Delete the maintenance record and verify the reminder disappears
      await StorageService.deleteMaintenanceRecord(record.id);

      // Switch to Reminders tab
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();
      expect(find.text('No Service Reminders'), findsOneWidget);

      // Switch to Home tab
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('No upcoming services scheduled.'), findsOneWidget);
    });
  });
}
