import 'service_request_dto.dart';

class ServiceRequestPageDto {
  final List<ServiceRequestDto> items;
  final int pageNumber;
  final int pageSize;
  final int totalCount;

  const ServiceRequestPageDto({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
  });

  factory ServiceRequestPageDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] ?? json['data'];

    return ServiceRequestPageDto(
      items: rawItems is List
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(ServiceRequestDto.fromJson)
                .toList()
          : const [],
      pageNumber: json['pageNumber'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 10,
      totalCount: json['totalCount'] as int? ?? 0,
    );
  }
}
