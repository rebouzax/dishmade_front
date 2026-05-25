import 'package:dishmade_front/features/categories/domain/entities/dish_category.dart';

class CategoryDto {
  final String id;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;

  const CategoryDto({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.createdAt,
  });

  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    return CategoryDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      isActive: json['isActive'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  DishCategory toEntity() {
    return DishCategory(
      id: id,
      name: name,
      description: description,
      isActive: isActive,
      createdAt: createdAt,
    );
  }
}
