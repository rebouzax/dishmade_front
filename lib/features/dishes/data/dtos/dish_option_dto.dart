import '../../domain/entities/dish_option.dart';

class DishOptionDto {
  final String id;
  final String optionGroupId;
  final String name;
  final double additionalPrice;
  final bool isAvailable;

  const DishOptionDto({
    required this.id,
    required this.optionGroupId,
    required this.name,
    required this.additionalPrice,
    required this.isAvailable,
  });

  factory DishOptionDto.fromJson(Map<String, dynamic> json) {
    return DishOptionDto(
      id: json['id']?.toString() ?? '',
      optionGroupId: json['optionGroupId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      additionalPrice: (json['additionalPrice'] as num?)?.toDouble() ?? 0,
      isAvailable: json['isAvailable'] as bool? ?? false,
    );
  }

  DishOption toEntity() {
    return DishOption(
      id: id,
      optionGroupId: optionGroupId,
      name: name,
      additionalPrice: additionalPrice,
      isAvailable: isAvailable,
    );
  }
}
