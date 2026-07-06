import '../enums/service_request_status.dart';
import '../enums/service_request_type.dart';

class ServiceRequest {
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

  const ServiceRequest({
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
}
