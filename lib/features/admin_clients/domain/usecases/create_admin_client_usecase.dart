import 'package:dishmade_front/features/admin_clients/domain/repositories/admin_clients_repository.dart';

class CreateAdminClientUseCase {
  final AdminClientsRepository _repository;

  const CreateAdminClientUseCase(this._repository);

  Future<String> call({
    required String restaurantName,
    String? restaurantDocument,
    required String userName,
    required String email,
    required String password,
  }) {
    return _repository.createClient(
      restaurantName: restaurantName,
      restaurantDocument: restaurantDocument,
      userName: userName,
      email: email,
      password: password,
    );
  }
}
