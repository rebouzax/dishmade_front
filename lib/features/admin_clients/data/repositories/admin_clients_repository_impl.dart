import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/pagination/paginated_response.dart';
import '../../domain/entities/admin_client.dart';
import '../../domain/repositories/admin_clients_repository.dart';
import '../datasources/admin_clients_remote_datasource.dart';
import '../dtos/create_admin_client_request.dart';

final adminClientsRepositoryProvider = Provider<AdminClientsRepository>((ref) {
  final remoteDataSource = ref.watch(adminClientsRemoteDataSourceProvider);
  return AdminClientsRepositoryImpl(remoteDataSource);
});

class AdminClientsRepositoryImpl implements AdminClientsRepository {
  final AdminClientsRemoteDataSource _remoteDataSource;

  const AdminClientsRepositoryImpl(this._remoteDataSource);

  @override
  Future<PaginatedResponse<AdminClient>> getClients({
    String? search,
    bool? isActive,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final response = await _remoteDataSource.getClients(
      search: search,
      isActive: isActive,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    return PaginatedResponse<AdminClient>(
      items: response.items.map((dto) => dto.toEntity()).toList(),
      pageNumber: response.pageNumber,
      pageSize: response.pageSize,
      totalCount: response.totalCount,
      totalPages: response.totalPages,
      hasPreviousPage: response.hasPreviousPage,
      hasNextPage: response.hasNextPage,
    );
  }

  @override
  Future<String> createClient({
    required String restaurantName,
    String? restaurantDocument,
    required String userName,
    required String email,
    required String password,
  }) {
    return _remoteDataSource.createClient(
      CreateAdminClientRequest(
        restaurantName: restaurantName,
        restaurantDocument: restaurantDocument,
        userName: userName,
        email: email,
        password: password,
      ),
    );
  }
}
