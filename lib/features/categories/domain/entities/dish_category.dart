class DishCategory {
  final String id;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;

  const DishCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.createdAt,
  });
}
