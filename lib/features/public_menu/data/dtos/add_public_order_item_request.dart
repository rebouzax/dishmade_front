class AddPublicOrderItemRequest {
  final String accessCode;
  final String dishId;
  final int quantity;
  final String? notes;
  final List<String> optionIds;

  const AddPublicOrderItemRequest({
    required this.accessCode,
    required this.dishId,
    required this.quantity,
    this.notes,
    this.optionIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'accessCode': accessCode,
      'dishId': dishId,
      'quantity': quantity,
      'optionIds': optionIds,
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
    };
  }
}
