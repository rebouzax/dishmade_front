class AddOrderItemRequest {
  final String dishId;
  final int quantity;
  final String? notes;

  const AddOrderItemRequest({
    required this.dishId,
    required this.quantity,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'dishId': dishId,
      'quantity': quantity,
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
    };
  }
}
