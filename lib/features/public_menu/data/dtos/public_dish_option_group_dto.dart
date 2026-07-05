import '../../domain/entities/public_dish_option_group.dart';
import 'public_dish_option_dto.dart';

class PublicDishOptionGroupDto {
  final String id;
  final String name;
  final bool isRequired;
  final int minSelection;
  final int maxSelection;
  final List<PublicDishOptionDto> options;

  const PublicDishOptionGroupDto({
    required this.id,
    required this.name,
    required this.isRequired,
    required this.minSelection,
    required this.maxSelection,
    required this.options,
  });

  factory PublicDishOptionGroupDto.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];

    return PublicDishOptionGroupDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      isRequired: json['isRequired'] as bool? ?? false,
      minSelection: json['minSelection'] as int? ?? 0,
      maxSelection: json['maxSelection'] as int? ?? 1,
      options: rawOptions is List
          ? rawOptions
                .whereType<Map<String, dynamic>>()
                .map(PublicDishOptionDto.fromJson)
                .toList()
          : const [],
    );
  }

  PublicDishOptionGroup toEntity() {
    return PublicDishOptionGroup(
      id: id,
      name: name,
      isRequired: isRequired,
      minSelection: minSelection,
      maxSelection: maxSelection,
      options: options.map((option) => option.toEntity()).toList(),
    );
  }
}
