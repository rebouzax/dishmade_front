import 'dish_option.dart';

class DishOptionGroup {
  final String id;
  final String dishId;
  final String name;
  final bool isRequired;
  final int minSelection;
  final int maxSelection;
  final bool isActive;
  final List<DishOption> options;

  const DishOptionGroup({
    required this.id,
    required this.dishId,
    required this.name,
    required this.isRequired,
    required this.minSelection,
    required this.maxSelection,
    required this.isActive,
    required this.options,
  });
}
