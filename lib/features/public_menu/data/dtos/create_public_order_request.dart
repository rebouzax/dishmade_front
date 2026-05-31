class CreatePublicOrderRequest {
  final String restaurantSlug;
  final int tableNumber;

  const CreatePublicOrderRequest({
    required this.restaurantSlug,
    required this.tableNumber,
  });

  Map<String, dynamic> toJson() {
    return {'restaurantSlug': restaurantSlug, 'tableNumber': tableNumber};
  }
}
