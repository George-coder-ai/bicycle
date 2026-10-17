import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bicycle.dart';
import '../models/maintenance.dart';

/// Service responsible for persisting data locally using SharedPreferences.
/// Stores bicycles and maintenance records as JSON lists so they remain available
/// even after closing or restarting the app.
class StorageService {
  static const String _bicyclesKey = 'bicycles_data';
  static const String _maintenanceKey = 'maintenance_data';

  // ---------------------------------------------------------------------------
  // Bicycle Operations
  // ---------------------------------------------------------------------------

  /// Retrieve all saved bicycles from SharedPreferences
  static Future<List<Bicycle>> getBicycles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_bicyclesKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decodedList = jsonDecode(jsonString) as List<dynamic>;
      return decodedList
          .map((item) => Bicycle.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If parsing fails, return empty list to prevent app crash
      return [];
    }
  }

  /// Save the entire list of bicycles to SharedPreferences
  static Future<void> saveBicycles(List<Bicycle> bicycles) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = bicycles.map((b) => b.toJson()).toList();
    await prefs.setString(_bicyclesKey, jsonEncode(jsonList));
  }

  /// Add a new bicycle
  static Future<void> addBicycle(Bicycle bicycle) async {
    final bicycles = await getBicycles();
    bicycles.add(bicycle);
    await saveBicycles(bicycles);
  }

  /// Update an existing bicycle
  static Future<void> updateBicycle(Bicycle updatedBicycle) async {
    final bicycles = await getBicycles();
    final index = bicycles.indexWhere((b) => b.id == updatedBicycle.id);
    if (index != -1) {
      bicycles[index] = updatedBicycle;
      await saveBicycles(bicycles);
    }
  }

  /// Delete a bicycle by ID and cascade delete all associated maintenance records
  static Future<void> deleteBicycle(String bicycleId) async {
    // 1. Remove bicycle from bicycles list
    final bicycles = await getBicycles();
    bicycles.removeWhere((b) => b.id == bicycleId);
    await saveBicycles(bicycles);

    // 2. Cascade delete associated maintenance records to avoid orphaned data
    final records = await getMaintenanceRecords();
    records.removeWhere((record) => record.bicycleId == bicycleId);
    await saveMaintenanceRecords(records);
  }

  // ---------------------------------------------------------------------------
  // Maintenance Operations
  // ---------------------------------------------------------------------------

  /// Retrieve all maintenance records from SharedPreferences
  static Future<List<MaintenanceRecord>> getMaintenanceRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_maintenanceKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decodedList = jsonDecode(jsonString) as List<dynamic>;
      return decodedList
          .map((item) =>
              MaintenanceRecord.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Save the entire list of maintenance records to SharedPreferences
  static Future<void> saveMaintenanceRecords(
      List<MaintenanceRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = records.map((r) => r.toJson()).toList();
    await prefs.setString(_maintenanceKey, jsonEncode(jsonList));
  }

  /// Add a new maintenance record
  static Future<void> addMaintenanceRecord(MaintenanceRecord record) async {
    final records = await getMaintenanceRecords();
    records.add(record);
    await saveMaintenanceRecords(records);
  }

  /// Update an existing maintenance record
  static Future<void> updateMaintenanceRecord(
      MaintenanceRecord updatedRecord) async {
    final records = await getMaintenanceRecords();
    final index = records.indexWhere((r) => r.id == updatedRecord.id);
    if (index != -1) {
      records[index] = updatedRecord;
      await saveMaintenanceRecords(records);
    }
  }

  /// Delete a single maintenance record by ID
  static Future<void> deleteMaintenanceRecord(String recordId) async {
    final records = await getMaintenanceRecords();
    records.removeWhere((r) => r.id == recordId);
    await saveMaintenanceRecords(records);
  }

  // ---------------------------------------------------------------------------
  // Helper / Aggregator Queries
  // ---------------------------------------------------------------------------

  /// Calculate total maintenance expenses across all records
  static Future<double> getTotalExpenses() async {
    final records = await getMaintenanceRecords();
    double total = 0.0;
    for (final record in records) {
      total += record.cost;
    }
    return total;
  }
}
