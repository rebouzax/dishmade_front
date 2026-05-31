class PublicDish {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String categoryId;
  final String categoryName;
  final String? imageUrl;

  const PublicDish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.categoryName,
    required this.imageUrl,
  });
}
