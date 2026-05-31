class AddPublicOrderItemRequest {
  final String accessCode;
  final String dishId;
  final int quantity;

  const AddPublicOrderItemRequest({
    required this.accessCode,
    required this.dishId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {'accessCode': accessCode, 'dishId': dishId, 'quantity': quantity};
  }
}
