import 'sale_history_item.dart';

class SaleHistory {
  final String orderId;
  final String tableId;
  final int tableNumber;
  final double total;
  final DateTime? saleDate;
  final List<SaleHistoryItem> items;

  const SaleHistory({
    required this.orderId,
    required this.tableId,
    required this.tableNumber,
    required this.total,
    required this.saleDate,
    required this.items,
  });

  int get totalItems {
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }
}
