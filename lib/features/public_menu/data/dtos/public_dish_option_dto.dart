import '../../domain/entities/public_dish_option.dart';

class PublicDishOptionDto {
  final String id;
  final String name;
  final double additionalPrice;

  const PublicDishOptionDto({
    required this.id,
    required this.name,
    required this.additionalPrice,
  });

  factory PublicDishOptionDto.fromJson(Map<String, dynamic> json) {
    return PublicDishOptionDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      additionalPrice: (json['additionalPrice'] as num?)?.toDouble() ?? 0,
    );
  }

  PublicDishOption toEntity() {
    return PublicDishOption(
      id: id,
      name: name,
      additionalPrice: additionalPrice,
    );
  }
}
