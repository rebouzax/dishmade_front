class Dish {
  final String id;
  final String name;
  final String description;
  final double price;
  final bool isAvailable;
  final String categoryId;
  final String categoryName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.isAvailable,
    required this.categoryId,
    required this.categoryName,
    required this.createdAt,
    required this.updatedAt,
  });
}
