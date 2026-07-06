class UpdateDishOptionRequest {
  final String name;
  final double additionalPrice;

  const UpdateDishOptionRequest({
    required this.name,
    required this.additionalPrice,
  });

  Map<String, dynamic> toJson() {
    return {'name': name.trim(), 'additionalPrice': additionalPrice};
  }
}
