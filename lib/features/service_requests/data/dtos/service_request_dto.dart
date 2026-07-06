import '../../domain/entities/service_request.dart';
import '../../domain/enums/service_request_status.dart';
import '../../domain/enums/service_request_type.dart';

class ServiceRequestDto {
  final String id;
  final String restaurantId;
  final String tableId;
  final int tableNumber;
  final ServiceRequestType type;
  final ServiceRequestStatus status;
  final String? message;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? resolvedAt;
  final DateTime? canceledAt;
  final DateTime? updatedAt;

  const ServiceRequestDto({
    required this.id,
    required this.restaurantId,
    required this.tableId,
    required this.tableNumber,
    required this.type,
    required this.status,
    required this.message,
    required this.createdAt,
    required this.startedAt,
    required this.resolvedAt,
    required this.canceledAt,
    required this.updatedAt,
  });

  factory ServiceRequestDto.fromJson(Map<String, dynamic> json) {
    return ServiceRequestDto(
      id: json['id']?.toString() ?? '',
      restaurantId: json['restaurantId']?.toString() ?? '',
      tableId: json['tableId']?.toString() ?? '',
      tableNumber: json['tableNumber'] as int? ?? 0,
      type: ServiceRequestTypeExtension.fromApi(json['type']),
      status: ServiceRequestStatusExtension.fromApi(json['status']),
      message: json['message']?.toString(),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      startedAt: DateTime.tryParse(json['startedAt']?.toString() ?? ''),
      resolvedAt: DateTime.tryParse(json['resolvedAt']?.toString() ?? ''),
      canceledAt: DateTime.tryParse(json['canceledAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  ServiceRequest toEntity() {
    return ServiceRequest(
      id: id,
      restaurantId: restaurantId,
      tableId: tableId,
      tableNumber: tableNumber,
      type: type,
      status: status,
      message: message,
      createdAt: createdAt,
      startedAt: startedAt,
      resolvedAt: resolvedAt,
      canceledAt: canceledAt,
      updatedAt: updatedAt,
    );
  }
}
