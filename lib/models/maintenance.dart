/// Model class representing a maintenance activity recorded for a bicycle.
class MaintenanceRecord {
  final String id;
  final String bicycleId;
  final String maintenanceType;
  final DateTime date;
  final double cost;
  final String notes;
  final DateTime? nextServiceDate;

  /// Standard list of maintenance types required by the project
  static const List<String> types = [
    'Chain Lubrication',
    'Brake Adjustment',
    'Tyre Replacement',
    'General Servicing',
    'Cleaning',
    'Other',
  ];

  MaintenanceRecord({
    required this.id,
    required this.bicycleId,
    required this.maintenanceType,
    required this.date,
    required this.cost,
    required this.notes,
    this.nextServiceDate,
  });

  /// Convert to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bicycleId': bicycleId,
      'maintenanceType': maintenanceType,
      'date': date.toIso8601String(),
      'cost': cost,
      'notes': notes,
      'nextServiceDate': nextServiceDate?.toIso8601String(),
    };
  }

  /// Create from JSON Map
  factory MaintenanceRecord.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['date'] as String);
    } catch (_) {
      parsedDate = DateTime.now();
    }

    DateTime? parsedNextServiceDate;
    final nextRaw = json['nextServiceDate'];
    if (nextRaw != null && nextRaw.toString().trim().isNotEmpty) {
      try {
        parsedNextServiceDate = DateTime.parse(nextRaw.toString().trim());
      } catch (_) {
        parsedNextServiceDate = null;
      }
    }

    return MaintenanceRecord(
      id: json['id']?.toString() ?? '',
      bicycleId: json['bicycleId']?.toString() ?? '',
      maintenanceType: json['maintenanceType']?.toString() ?? 'Other',
      date: parsedDate,
      cost: (json['cost'] is num)
          ? (json['cost'] as num).toDouble()
          : (double.tryParse(json['cost']?.toString() ?? '0') ?? 0.0),
      notes: json['notes']?.toString() ?? '',
      nextServiceDate: parsedNextServiceDate,
    );
  }

  /// Helper to create a modified copy
  MaintenanceRecord copyWith({
    String? id,
    String? bicycleId,
    String? maintenanceType,
    DateTime? date,
    double? cost,
    String? notes,
    DateTime? nextServiceDate,
    bool clearNextServiceDate = false,
  }) {
    return MaintenanceRecord(
      id: id ?? this.id,
      bicycleId: bicycleId ?? this.bicycleId,
      maintenanceType: maintenanceType ?? this.maintenanceType,
      date: date ?? this.date,
      cost: cost ?? this.cost,
      notes: notes ?? this.notes,
      nextServiceDate: clearNextServiceDate
          ? null
          : (nextServiceDate ?? this.nextServiceDate),
    );
  }
}
