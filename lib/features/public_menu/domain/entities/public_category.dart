import 'public_dish.dart';

class PublicCategory {
  final String id;
  final String name;
  final String? description;
  final List<PublicDish> dishes;

  const PublicCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.dishes,
  });
}
