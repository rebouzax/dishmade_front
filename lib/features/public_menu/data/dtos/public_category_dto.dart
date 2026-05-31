import '../../domain/entities/public_category.dart';
import 'public_dish_dto.dart';

class PublicCategoryDto {
  final String id;
  final String name;
  final String? description;
  final List<PublicDishDto> dishes;

  const PublicCategoryDto({
    required this.id,
    required this.name,
    required this.description,
    required this.dishes,
  });

  factory PublicCategoryDto.fromJson(Map<String, dynamic> json) {
    final rawDishes = json['dishes'];

    return PublicCategoryDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      dishes: rawDishes is List
          ? rawDishes
                .whereType<Map<String, dynamic>>()
                .map(PublicDishDto.fromJson)
                .toList()
          : const [],
    );
  }

  PublicCategory toEntity() {
    return PublicCategory(
      id: id,
      name: name,
      description: description,
      dishes: dishes.map((dish) => dish.toEntity()).toList(),
    );
  }
}
