import '../../domain/entities/public_dish.dart';

class PublicDishDto {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String categoryId;
  final String categoryName;
  final String? imageUrl;

  const PublicDishDto({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.categoryName,
    required this.imageUrl,
  });

  factory PublicDishDto.fromJson(Map<String, dynamic> json) {
    return PublicDishDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
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
    );
  }
}
