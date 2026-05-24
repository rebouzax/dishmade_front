import '../../domain/entities/dish.dart';

class DishDto {
  final String id;
  final String name;
  final String description;
  final double price;
  final bool isAvailable;
  final String categoryId;
  final String categoryName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DishDto({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.isAvailable,
    required this.categoryId,
    required this.categoryName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DishDto.fromJson(Map<String, dynamic> json) {
    return DishDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      isAvailable: json['isAvailable'] as bool? ?? false,
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  Dish toEntity() {
    return Dish(
      id: id,
      name: name,
      description: description,
      price: price,
      isAvailable: isAvailable,
      categoryId: categoryId,
      categoryName: categoryName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
