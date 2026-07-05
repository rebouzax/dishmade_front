class DishOption {
  final String id;
  final String optionGroupId;
  final String name;
  final double additionalPrice;
  final bool isAvailable;

  const DishOption({
    required this.id,
    required this.optionGroupId,
    required this.name,
    required this.additionalPrice,
    required this.isAvailable,
  });
}
