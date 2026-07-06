import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../domain/entities/service_request.dart';
import '../../domain/enums/service_request_status.dart';
import '../../domain/enums/service_request_type.dart';
import '../../domain/repositories/service_request_repository.dart';
import '../datasources/service_request_remote_datasource.dart';
import '../dtos/create_public_service_request_request.dart';

final serviceRequestRemoteDataSourceProvider =
    Provider<ServiceRequestRemoteDataSource>((ref) {
      final dio = ref.watch(dioProvider);
      return ServiceRequestRemoteDataSourceImpl(dio);
    });

final serviceRequestRepositoryProvider = Provider<ServiceRequestRepository>((
  ref,
) {
  final remoteDataSource = ref.watch(serviceRequestRemoteDataSourceProvider);
  return ServiceRequestRepositoryImpl(remoteDataSource);
});

class ServiceRequestRepositoryImpl implements ServiceRequestRepository {
  final ServiceRequestRemoteDataSource _remoteDataSource;

  const ServiceRequestRepositoryImpl(this._remoteDataSource);

  @override
  Future<ServiceRequest> createPublic({
    required String restaurantSlug,
    required int tableNumber,
    required ServiceRequestType type,
    String? message,
  }) async {
    final response = await _remoteDataSource.createPublic(
      request: CreatePublicServiceRequestRequest(
        restaurantSlug: restaurantSlug,
        tableNumber: tableNumber,
        type: type,
        message: message,
      ),
    );
    return response.toEntity();
  }

  @override
  Future<ServiceRequestPage> getAll({
    ServiceRequestStatus? status,
    ServiceRequestType? type,
    String? tableId,
    required int pageNumber,
    required int pageSize,
  }) async {
    final response = await _remoteDataSource.getAll(
      status: status?.apiValue,
      type: type?.apiValue,
      tableId: tableId,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
    return ServiceRequestPage(
      items: response.items.map((item) => item.toEntity()).toList(),
      pageNumber: response.pageNumber,
      pageSize: response.pageSize,
      totalCount: response.totalCount,
    );
  }

  @override
  Future<ServiceRequest> start({required String id}) async {
    final response = await _remoteDataSource.start(id: id);
    return response.toEntity();
  }

  @override
  Future<ServiceRequest> resolve({required String id}) async {
    final response = await _remoteDataSource.resolve(id: id);
    return response.toEntity();
  }

  @override
  Future<ServiceRequest> cancel({required String id}) async {
    final response = await _remoteDataSource.cancel(id: id);
    return response.toEntity();
  }
}
