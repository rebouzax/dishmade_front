class CreateDishRequest {
  final String name;
  final String description;
  final double price;
  final String categoryId;

  const CreateDishRequest({
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'categoryId': categoryId,
    };
  }
}
