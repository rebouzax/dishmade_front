import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/table_repository_impl.dart';
import '../../domain/usecases/get_table_menu_qr_code_image_usecase.dart';

final getTableMenuQrCodeImageUseCaseProvider =
    Provider<GetTableMenuQrCodeImageUseCase>((ref) {
      final repository = ref.watch(tableRepositoryProvider);
      return GetTableMenuQrCodeImageUseCase(repository);
    });

final tableMenuQrCodeImageProvider = FutureProvider.autoDispose
    .family<Uint8List, String>((ref, tableId) async {
      final useCase = ref.watch(getTableMenuQrCodeImageUseCaseProvider);
      return useCase(id: tableId);
    });
