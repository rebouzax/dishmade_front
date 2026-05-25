import 'package:dishmade_front/features/admin_clients/domain/entities/admin_client.dart';

import '../../../../core/pagination/paginated_response.dart';

abstract interface class AdminClientsRepository {
  Future<PaginatedResponse<AdminClient>> getClients({
    String? search,
    bool? isActive,
    int pageNumber = 1,
    int pageSize = 20,
  });

  Future<String> createClient({
    required String restaurantName,
    String? restaurantDocument,
    required String userName,
    required String email,
    required String password,
  });
}
