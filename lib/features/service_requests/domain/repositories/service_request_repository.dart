import '../entities/service_request.dart';
import '../enums/service_request_status.dart';
import '../enums/service_request_type.dart';

class ServiceRequestPage {
  final List<ServiceRequest> items;
  final int pageNumber;
  final int pageSize;
  final int totalCount;

  const ServiceRequestPage({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
  });
}

abstract interface class ServiceRequestRepository {
  Future<ServiceRequest> createPublic({
    required String restaurantSlug,
    required int tableNumber,
    required ServiceRequestType type,
    String? message,
  });

  Future<ServiceRequestPage> getAll({
    ServiceRequestStatus? status,
    ServiceRequestType? type,
    String? tableId,
    required int pageNumber,
    required int pageSize,
  });

  Future<ServiceRequest> start({required String id});

  Future<ServiceRequest> resolve({required String id});

  Future<ServiceRequest> cancel({required String id});
}
