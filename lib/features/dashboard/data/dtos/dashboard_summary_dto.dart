import '../../domain/entities/dashboard_summary.dart';
import 'top_dish_dto.dart';

class DashboardSummaryDto {
  final double totalRevenue;
  final int totalOrders;
  final int totalItemsSold;
  final double averageTicket;
  final List<TopDishDto> topDishes;

  const DashboardSummaryDto({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalItemsSold,
    required this.averageTicket,
    required this.topDishes,
  });

  factory DashboardSummaryDto.fromJson(Map<String, dynamic> json) {
    final rawTopDishes = json['topDishes'];

    return DashboardSummaryDto(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      totalOrders: json['totalOrders'] as int? ?? 0,
      totalItemsSold: json['totalItemsSold'] as int? ?? 0,
      averageTicket: (json['averageTicket'] as num?)?.toDouble() ?? 0,
      topDishes: rawTopDishes is List
          ? rawTopDishes
                .whereType<Map<String, dynamic>>()
                .map(TopDishDto.fromJson)
                .toList()
          : const [],
    );
  }

  DashboardSummary toEntity() {
    return DashboardSummary(
      totalRevenue: totalRevenue,
      totalOrders: totalOrders,
      totalItemsSold: totalItemsSold,
      averageTicket: averageTicket,
      topDishes: topDishes.map((dish) => dish.toEntity()).toList(),
    );
  }
}
