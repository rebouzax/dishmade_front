import '../../domain/entities/restaurant_table.dart';

class RestaurantTableDto {
  final String id;
  final int number;
  final bool isOccupied;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RestaurantTableDto({
    required this.id,
    required this.number,
    required this.isOccupied,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RestaurantTableDto.fromJson(Map<String, dynamic> json) {
    return RestaurantTableDto(
      id: json['id']?.toString() ?? '',
      number: json['number'] as int? ?? 0,
      isOccupied: json['isOccupied'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  RestaurantTable toEntity() {
    return RestaurantTable(
      id: id,
      number: number,
      isOccupied: isOccupied,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
