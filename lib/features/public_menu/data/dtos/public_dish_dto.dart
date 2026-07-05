import '../../domain/entities/public_dish.dart';
import 'public_dish_option_group_dto.dart';

class PublicDishDto {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String categoryId;
  final String categoryName;
  final String? imageUrl;
  final List<PublicDishOptionGroupDto> optionGroups;

  const PublicDishDto({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.categoryName,
    required this.imageUrl,
    required this.optionGroups,
  });

  factory PublicDishDto.fromJson(Map<String, dynamic> json) {
    final rawOptionGroups = json['optionGroups'];

    return PublicDishDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      optionGroups: rawOptionGroups is List
          ? rawOptionGroups
                .whereType<Map<String, dynamic>>()
                .map(PublicDishOptionGroupDto.fromJson)
                .toList()
          : const [],
    );
  }

  PublicDish toEntity() {
    return PublicDish(
      id: id,
      name: name,
      description: description,
      price: price,
      categoryId: categoryId,
      categoryName: categoryName,
      imageUrl: imageUrl,
      optionGroups: optionGroups.map((group) => group.toEntity()).toList(),
    );
  }
}
