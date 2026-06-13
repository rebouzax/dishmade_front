import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:typed_data';

import '../../../../core/pagination/paginated_response.dart';
import '../../domain/entities/restaurant_table.dart';
import '../../domain/entities/table_menu_qr_code.dart';
import '../../domain/repositories/table_repository.dart';
import '../datasources/table_remote_datasource.dart';
import '../dtos/create_table_request.dart';
import '../dtos/update_table_request.dart';

final tableRepositoryProvider = Provider<TableRepository>((ref) {
  final remoteDataSource = ref.watch(tableRemoteDataSourceProvider);
  return TableRepositoryImpl(remoteDataSource);
});

class TableRepositoryImpl implements TableRepository {
  final TableRemoteDataSource _remoteDataSource;

  const TableRepositoryImpl(this._remoteDataSource);

  @override
  Future<PaginatedResponse<RestaurantTable>> getTables({
    int? number,
    bool? isOccupied,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final response = await _remoteDataSource.getTables(
      number: number,
      isOccupied: isOccupied,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    return PaginatedResponse<RestaurantTable>(
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
  Future<String> createTable({required int number}) {
    return _remoteDataSource.createTable(CreateTableRequest(number: number));
  }

  @override
  Future<void> updateTable({required String id, required int number}) {
    return _remoteDataSource.updateTable(
      id: id,
      request: UpdateTableRequest(number: number),
    );
  }

  @override
  Future<void> occupyTable({required String id}) {
    return _remoteDataSource.occupyTable(id: id);
  }

  @override
  Future<void> releaseTable({required String id}) {
    return _remoteDataSource.releaseTable(id: id);
  }

  @override
  Future<void> deleteTable({required String id}) {
    return _remoteDataSource.deleteTable(id: id);
  }

  @override
  Future<TableMenuQrCode> enableMenuQrCode({required String id}) async {
    final response = await _remoteDataSource.enableMenuQrCode(id: id);
    return response.toEntity();
  }

  @override
  Future<void> disableMenuQrCode({required String id}) {
    return _remoteDataSource.disableMenuQrCode(id: id);
  }

  @override
  Future<TableMenuQrCode> getMenuQrCode({required String id}) async {
    final response = await _remoteDataSource.getMenuQrCode(id: id);
    return response.toEntity();
  }

  @override
  Future<Uint8List> getMenuQrCodeImage({required String id}) {
    return _remoteDataSource.getMenuQrCodeImage(id: id);
  }
}
