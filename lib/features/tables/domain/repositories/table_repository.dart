import 'dart:typed_data';

import '../../../../core/pagination/paginated_response.dart';
import '../entities/restaurant_table.dart';
import '../entities/table_menu_qr_code.dart';

abstract interface class TableRepository {
  Future<PaginatedResponse<RestaurantTable>> getTables({
    int? number,
    bool? isOccupied,
    int pageNumber = 1,
    int pageSize = 20,
  });

  Future<String> createTable({required int number});

  Future<void> updateTable({required String id, required int number});

  Future<void> occupyTable({required String id});

  Future<void> releaseTable({required String id});

  Future<void> deleteTable({required String id});

  Future<TableMenuQrCode> enableMenuQrCode({required String id});

  Future<void> disableMenuQrCode({required String id});

  Future<TableMenuQrCode> getMenuQrCode({required String id});

  Future<Uint8List> getMenuQrCodeImage({required String id});
}
