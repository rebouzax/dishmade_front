import '../../domain/entities/public_menu.dart';
import 'public_category_dto.dart';

class PublicMenuDto {
  final String restaurantId;
  final String restaurantName;
  final String slug;
  final String menuUrl;
  final String qrCodeUrl;
  final List<PublicCategoryDto> categories;

  const PublicMenuDto({
    required this.restaurantId,
    required this.restaurantName,
    required this.slug,
    required this.menuUrl,
    required this.qrCodeUrl,
    required this.categories,
  });

  factory PublicMenuDto.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['categories'];

    return PublicMenuDto(
      restaurantId: json['restaurantId']?.toString() ?? '',
      restaurantName: json['restaurantName']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      menuUrl: json['menuUrl']?.toString() ?? '',
      qrCodeUrl: json['qrCodeUrl']?.toString() ?? '',
      categories: rawCategories is List
          ? rawCategories
                .whereType<Map<String, dynamic>>()
                .map(PublicCategoryDto.fromJson)
                .toList()
          : const [],
    );
  }

  PublicMenu toEntity() {
    return PublicMenu(
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      slug: slug,
      menuUrl: menuUrl,
      qrCodeUrl: qrCodeUrl,
      categories: categories.map((category) => category.toEntity()).toList(),
    );
  }
}
