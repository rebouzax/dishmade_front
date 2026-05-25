class SaleHistoryItem {
  final String dishId;
  final String dishName;
  final int quantity;
  final double unitPrice;
  final double total;

  const SaleHistoryItem({
    required this.dishId,
    required this.dishName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });
}
