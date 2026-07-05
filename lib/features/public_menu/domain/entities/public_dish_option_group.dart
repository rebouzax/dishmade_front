import 'public_dish_option.dart';

class PublicDishOptionGroup {
  final String id;
  final String name;
  final bool isRequired;
  final int minSelection;
  final int maxSelection;
  final List<PublicDishOption> options;

  const PublicDishOptionGroup({
    required this.id,
    required this.name,
    required this.isRequired,
    required this.minSelection,
    required this.maxSelection,
    required this.options,
  });
}
