import '../../domain/entities/dish_option_group.dart';
import 'dish_option_dto.dart';

class DishOptionGroupDto {
  final String id;
  final String dishId;
  final String name;
  final bool isRequired;
  final int minSelection;
  final int maxSelection;
  final bool isActive;
  final List<DishOptionDto> options;

  const DishOptionGroupDto({
    required this.id,
    required this.dishId,
    required this.name,
    required this.isRequired,
    required this.minSelection,
    required this.maxSelection,
    required this.isActive,
    required this.options,
  });

  factory DishOptionGroupDto.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];

    return DishOptionGroupDto(
      id: json['id']?.toString() ?? '',
      dishId: json['dishId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      isRequired: json['isRequired'] as bool? ?? false,
      minSelection: json['minSelection'] as int? ?? 0,
      maxSelection: json['maxSelection'] as int? ?? 1,
      isActive: json['isActive'] as bool? ?? false,
      options: rawOptions is List
          ? rawOptions
                .whereType<Map<String, dynamic>>()
                .map(DishOptionDto.fromJson)
                .toList()
          : const [],
    );
  }

  DishOptionGroup toEntity() {
    return DishOptionGroup(
      id: id,
      dishId: dishId,
      name: name,
      isRequired: isRequired,
      minSelection: minSelection,
      maxSelection: maxSelection,
      isActive: isActive,
      options: options.map((option) => option.toEntity()).toList(),
    );
  }
}
