import '../../domain/entities/sale_history.dart';
import 'sale_history_item_dto.dart';

class SaleHistoryDto {
  final String orderId;
  final String tableId;
  final int tableNumber;
  final double total;
  final DateTime? saleDate;
  final List<SaleHistoryItemDto> items;

  const SaleHistoryDto({
    required this.orderId,
    required this.tableId,
    required this.tableNumber,
    required this.total,
    required this.saleDate,
    required this.items,
  });

  factory SaleHistoryDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];

    return SaleHistoryDto(
      orderId: json['orderId']?.toString() ?? '',
      tableId: json['tableId']?.toString() ?? '',
      tableNumber: json['tableNumber'] as int? ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      saleDate: DateTime.tryParse(json['saleDate']?.toString() ?? ''),
      items: rawItems is List
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(SaleHistoryItemDto.fromJson)
                .toList()
          : const [],
    );
  }

  SaleHistory toEntity() {
    return SaleHistory(
      orderId: orderId,
      tableId: tableId,
      tableNumber: tableNumber,
      total: total,
      saleDate: saleDate,
      items: items.map((item) => item.toEntity()).toList(),
    );
  }
}
