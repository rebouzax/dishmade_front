import '../../domain/entities/top_dish.dart';

class TopDishDto {
  final String dishId;
  final String dishName;
  final int quantitySold;
  final double revenue;

  const TopDishDto({
    required this.dishId,
    required this.dishName,
    required this.quantitySold,
    required this.revenue,
  });

  factory TopDishDto.fromJson(Map<String, dynamic> json) {
    return TopDishDto(
      dishId: json['dishId']?.toString() ?? '',
      dishName: json['dishName']?.toString() ?? '',
      quantitySold: json['quantitySold'] as int? ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
    );
  }

  TopDish toEntity() {
    return TopDish(
      dishId: dishId,
      dishName: dishName,
      quantitySold: quantitySold,
      revenue: revenue,
    );
  }
}
