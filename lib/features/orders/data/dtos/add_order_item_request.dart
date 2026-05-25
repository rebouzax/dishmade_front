class AddOrderItemRequest {
  final String dishId;
  final int quantity;

  const AddOrderItemRequest({required this.dishId, required this.quantity});

  Map<String, dynamic> toJson() {
    return {'dishId': dishId, 'quantity': quantity};
  }
}
