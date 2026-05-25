import 'package:dishmade_front/features/admin_clients/domain/repositories/admin_clients_repository.dart';

import '../../../../core/pagination/paginated_response.dart';
import '../entities/admin_client.dart';

class GetAdminClientsUseCase {
  final AdminClientsRepository _repository;

  const GetAdminClientsUseCase(this._repository);

  Future<PaginatedResponse<AdminClient>> call({
    String? search,
    bool? isActive,
    int pageNumber = 1,
    int pageSize = 20,
  }) {
    return _repository.getClients(
      search: search,
      isActive: isActive,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
