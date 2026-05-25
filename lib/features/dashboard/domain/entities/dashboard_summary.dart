import 'top_dish.dart';

class DashboardSummary {
  final double totalRevenue;
  final int totalOrders;
  final int totalItemsSold;
  final double averageTicket;
  final List<TopDish> topDishes;

  const DashboardSummary({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalItemsSold,
    required this.averageTicket,
    required this.topDishes,
  });

  const DashboardSummary.empty()
    : totalRevenue = 0,
      totalOrders = 0,
      totalItemsSold = 0,
      averageTicket = 0,
      topDishes = const [];
}
