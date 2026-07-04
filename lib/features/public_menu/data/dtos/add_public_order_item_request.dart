class AddPublicOrderItemRequest {
  final String accessCode;
  final String dishId;
  final int quantity;
  final String? notes;

  const AddPublicOrderItemRequest({
    required this.accessCode,
    required this.dishId,
    required this.quantity,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'accessCode': accessCode,
      'dishId': dishId,
      'quantity': quantity,
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
    };
  }
}
