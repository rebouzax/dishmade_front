import 'dart:typed_data';

import '../repositories/table_repository.dart';

class GetTableMenuQrCodeImageUseCase {
  final TableRepository _repository;

  const GetTableMenuQrCodeImageUseCase(this._repository);

  Future<Uint8List> call({required String id}) {
    return _repository.getMenuQrCodeImage(id: id);
  }
}
