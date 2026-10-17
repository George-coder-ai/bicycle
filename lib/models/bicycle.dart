/// Model class representing a user's bicycle.
/// Serializes to and from JSON for persistent storage in SharedPreferences.
class Bicycle {
  final String id;
  final String name;
  final String brand;
  final String model;
  final DateTime purchaseDate;

  Bicycle({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.purchaseDate,
  });

  /// Convert Bicycle instance to a JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'model': model,
      'purchaseDate': purchaseDate.toIso8601String(),
    };
  }

  /// Create a Bicycle instance from a JSON Map
  factory Bicycle.fromJson(Map<String, dynamic> json) {
    return Bicycle(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
    );
  }

  /// Helper to create a modified copy of this bicycle
  Bicycle copyWith({
    String? id,
    String? name,
    String? brand,
    String? model,
    DateTime? purchaseDate,
  }) {
    return Bicycle(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      purchaseDate: purchaseDate ?? this.purchaseDate,
    );
  }
}
