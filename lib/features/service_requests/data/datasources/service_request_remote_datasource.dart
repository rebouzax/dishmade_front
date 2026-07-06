import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/app_exception.dart';
import '../dtos/create_public_service_request_request.dart';
import '../dtos/service_request_dto.dart';
import '../dtos/service_request_page_dto.dart';

abstract interface class ServiceRequestRemoteDataSource {
  Future<ServiceRequestDto> createPublic({
    required CreatePublicServiceRequestRequest request,
  });

  Future<ServiceRequestPageDto> getAll({
    String? status,
    String? type,
    String? tableId,
    required int pageNumber,
    required int pageSize,
  });

  Future<ServiceRequestDto> getById({required String id});

  Future<ServiceRequestDto> start({required String id});

  Future<ServiceRequestDto> resolve({required String id});

  Future<ServiceRequestDto> cancel({required String id});
}

class ServiceRequestRemoteDataSourceImpl
    implements ServiceRequestRemoteDataSource {
  final Dio _dio;

  const ServiceRequestRemoteDataSourceImpl(this._dio);

  @override
  Future<ServiceRequestDto> createPublic({
    required CreatePublicServiceRequestRequest request,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.publicServiceRequests,
        data: request.toJson(),
      );
      return ServiceRequestDto.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<ServiceRequestPageDto> getAll({
    String? status,
    String? type,
    String? tableId,
    required int pageNumber,
    required int pageSize,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.serviceRequests,
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          if (status != null) 'status': status,
          if (type != null) 'type': type,
          if (tableId != null) 'tableId': tableId,
        },
      );
      return ServiceRequestPageDto.fromJson(
        response.data ?? <String, dynamic>{},
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<ServiceRequestDto> getById({required String id}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.serviceRequestById(id),
      );
      return ServiceRequestDto.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<ServiceRequestDto> start({required String id}) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        ApiEndpoints.startServiceRequest(id),
      );
      return ServiceRequestDto.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<ServiceRequestDto> resolve({required String id}) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        ApiEndpoints.resolveServiceRequest(id),
      );
      return ServiceRequestDto.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<ServiceRequestDto> cancel({required String id}) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        ApiEndpoints.cancelServiceRequest(id),
      );
      return ServiceRequestDto.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }
}
