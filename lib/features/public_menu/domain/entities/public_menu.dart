import 'public_category.dart';
import 'public_dish.dart';

class PublicMenu {
  final String restaurantId;
  final String restaurantName;
  final String slug;
  final String menuUrl;
  final String qrCodeUrl;
  final List<PublicCategory> categories;

  const PublicMenu({
    required this.restaurantId,
    required this.restaurantName,
    required this.slug,
    required this.menuUrl,
    required this.qrCodeUrl,
    required this.categories,
  });

  List<PublicDish> get allDishes {
    return categories.expand((category) => category.dishes).toList();
  }
}
