import '../../domain/entities/admin_client.dart';

const _unset = Object();

class AdminClientsState {
  final List<AdminClient> clients;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isSaving;
  final String? errorMessage;

  final String search;
  final bool? isActive;

  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;

  const AdminClientsState({
    this.clients = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isSaving = false,
    this.errorMessage,
    this.search = '',
    this.isActive,
    this.pageNumber = 1,
    this.pageSize = 20,
    this.totalCount = 0,
    this.totalPages = 0,
    this.hasNextPage = false,
  });

  AdminClientsState copyWith({
    List<AdminClient>? clients,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSaving,
    Object? errorMessage = _unset,
    String? search,
    Object? isActive = _unset,
    int? pageNumber,
    int? pageSize,
    int? totalCount,
    int? totalPages,
    bool? hasNextPage,
  }) {
    return AdminClientsState(
      clients: clients ?? this.clients,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      search: search ?? this.search,
      isActive: isActive == _unset ? this.isActive : isActive as bool?,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }
}
