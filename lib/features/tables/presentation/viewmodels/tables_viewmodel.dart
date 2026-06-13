import 'package:dishmade_front/features/tables/domain/usecases/disable_table_menu_qr_code_usecase.dart';
import 'package:dishmade_front/features/tables/domain/usecases/enable_table_menu_qr_code_usecase.dart';
import 'package:dishmade_front/features/tables/domain/usecases/get_table_menu_qr_code_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/repositories/table_repository_impl.dart';
import '../../domain/usecases/create_table_usecase.dart';
import '../../domain/usecases/delete_table_usecase.dart';
import '../../domain/usecases/get_tables_usecase.dart';
import '../../domain/usecases/occupy_table_usecase.dart';
import '../../domain/usecases/release_table_usecase.dart';
import '../../domain/usecases/update_table_usecase.dart';
import 'tables_state.dart';

final getTablesUseCaseProvider = Provider<GetTablesUseCase>((ref) {
  final repository = ref.watch(tableRepositoryProvider);
  return GetTablesUseCase(repository);
});

final createTableUseCaseProvider = Provider<CreateTableUseCase>((ref) {
  final repository = ref.watch(tableRepositoryProvider);
  return CreateTableUseCase(repository);
});

final updateTableUseCaseProvider = Provider<UpdateTableUseCase>((ref) {
  final repository = ref.watch(tableRepositoryProvider);
  return UpdateTableUseCase(repository);
});

final occupyTableUseCaseProvider = Provider<OccupyTableUseCase>((ref) {
  final repository = ref.watch(tableRepositoryProvider);
  return OccupyTableUseCase(repository);
});

final releaseTableUseCaseProvider = Provider<ReleaseTableUseCase>((ref) {
  final repository = ref.watch(tableRepositoryProvider);
  return ReleaseTableUseCase(repository);
});

final deleteTableUseCaseProvider = Provider<DeleteTableUseCase>((ref) {
  final repository = ref.watch(tableRepositoryProvider);
  return DeleteTableUseCase(repository);
});

final enableTableMenuQrCodeUseCaseProvider = Provider((ref) {
  final repository = ref.watch(tableRepositoryProvider);
  return EnableTableMenuQrCodeUseCase(repository);
});

final disableTableMenuQrCodeUseCaseProvider = Provider((ref) {
  final repository = ref.watch(tableRepositoryProvider);
  return DisableTableMenuQrCodeUseCase(repository);
});

final getTableMenuQrCodeUseCaseProvider = Provider((ref) {
  final repository = ref.watch(tableRepositoryProvider);
  return GetTableMenuQrCodeUseCase(repository);
});

final tablesViewModelProvider =
    NotifierProvider.autoDispose<TablesViewModel, TablesState>(
      TablesViewModel.new,
    );

class TablesViewModel extends Notifier<TablesState> {
  late final GetTablesUseCase _getTablesUseCase;
  late final CreateTableUseCase _createTableUseCase;
  late final UpdateTableUseCase _updateTableUseCase;
  late final OccupyTableUseCase _occupyTableUseCase;
  late final ReleaseTableUseCase _releaseTableUseCase;
  late final DeleteTableUseCase _deleteTableUseCase;
  late final EnableTableMenuQrCodeUseCase _enableTableMenuQrCodeUseCase;
  late final DisableTableMenuQrCodeUseCase _disableTableMenuQrCodeUseCase;
  late final GetTableMenuQrCodeUseCase _getTableMenuQrCodeUseCase;

  @override
  TablesState build() {
    _getTablesUseCase = ref.watch(getTablesUseCaseProvider);
    _createTableUseCase = ref.watch(createTableUseCaseProvider);
    _updateTableUseCase = ref.watch(updateTableUseCaseProvider);
    _occupyTableUseCase = ref.watch(occupyTableUseCaseProvider);
    _releaseTableUseCase = ref.watch(releaseTableUseCaseProvider);
    _deleteTableUseCase = ref.watch(deleteTableUseCaseProvider);
    _enableTableMenuQrCodeUseCase = ref.watch(
      enableTableMenuQrCodeUseCaseProvider,
    );
    _disableTableMenuQrCodeUseCase = ref.watch(
      disableTableMenuQrCodeUseCaseProvider,
    );
    _getTableMenuQrCodeUseCase = ref.watch(getTableMenuQrCodeUseCaseProvider);

    Future.microtask(loadInitial);

    return const TablesState();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      pageNumber: 1,
      hasNextPage: false,
    );

    try {
      final response = await _getTablesUseCase(
        number: state.number,
        isOccupied: state.isOccupied,
        pageNumber: 1,
        pageSize: state.pageSize,
      );

      if (!ref.mounted) return;

      state = state.copyWith(
        tables: response.items,
        isLoading: false,
        pageNumber: response.pageNumber,
        totalCount: response.totalCount,
        totalPages: response.totalPages,
        hasNextPage: response.hasNextPage,
      );
    } catch (error) {
      if (!ref.mounted) return;

      state = state.copyWith(isLoading: false, errorMessage: _mapError(error));
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasNextPage) {
      return;
    }

    final nextPage = state.pageNumber + 1;

    state = state.copyWith(isLoadingMore: true, errorMessage: null);

    try {
      final response = await _getTablesUseCase(
        number: state.number,
        isOccupied: state.isOccupied,
        pageNumber: nextPage,
        pageSize: state.pageSize,
      );

      if (!ref.mounted) return;

      state = state.copyWith(
        tables: [...state.tables, ...response.items],
        isLoadingMore: false,
        pageNumber: response.pageNumber,
        totalCount: response.totalCount,
        totalPages: response.totalPages,
        hasNextPage: response.hasNextPage,
      );
    } catch (error) {
      if (!ref.mounted) return;

      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: _mapError(error),
      );
    }
  }

  Future<void> setOccupiedFilter(bool? value) async {
    state = state.copyWith(isOccupied: value);
    await loadInitial();
  }

  Future<void> setNumberFilter(int? value) async {
    state = state.copyWith(number: value);
    await loadInitial();
  }

  Future<bool> createTable(int number) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _createTableUseCase(number: number);

      if (!ref.mounted) return false;

      state = state.copyWith(isSaving: false);
      await loadInitial();
      return true;
    } catch (error) {
      if (!ref.mounted) return false;

      state = state.copyWith(isSaving: false, errorMessage: _mapError(error));
      return false;
    }
  }

  Future<bool> updateTable({required String id, required int number}) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _updateTableUseCase(id: id, number: number);

      if (!ref.mounted) return false;

      state = state.copyWith(isSaving: false);
      await loadInitial();
      return true;
    } catch (error) {
      if (!ref.mounted) return false;

      state = state.copyWith(isSaving: false, errorMessage: _mapError(error));
      return false;
    }
  }

  Future<bool> occupyTable(String id) async {
    return _executeAction(() => _occupyTableUseCase(id: id));
  }

  Future<bool> releaseTable(String id) async {
    return _executeAction(() => _releaseTableUseCase(id: id));
  }

  Future<bool> deleteTable(String id) async {
    return _executeAction(() => _deleteTableUseCase(id: id));
  }

  Future<bool> _executeAction(Future<void> Function() action) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await action();

      if (!ref.mounted) return false;

      state = state.copyWith(isSaving: false);
      await loadInitial();
      return true;
    } catch (error) {
      if (!ref.mounted) return false;

      state = state.copyWith(isSaving: false, errorMessage: _mapError(error));
      return false;
    }
  }

  Future enableMenuQrCode(String tableId) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final qrCode = await _enableTableMenuQrCodeUseCase(id: tableId);

      if (!ref.mounted) return null;

      state = state.copyWith(isSaving: false);
      await loadInitial();

      return qrCode;
    } catch (error) {
      if (!ref.mounted) return null;

      state = state.copyWith(isSaving: false, errorMessage: _mapError(error));

      return null;
    }
  }

  Future disableMenuQrCode(String tableId) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _disableTableMenuQrCodeUseCase(id: tableId);

      if (!ref.mounted) return false;

      state = state.copyWith(isSaving: false);
      await loadInitial();

      return true;
    } catch (error) {
      if (!ref.mounted) return false;

      state = state.copyWith(isSaving: false, errorMessage: _mapError(error));

      return false;
    }
  }

  Future getMenuQrCode(String tableId) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final qrCode = await _getTableMenuQrCodeUseCase(id: tableId);

      if (!ref.mounted) return null;

      state = state.copyWith(isSaving: false);
      return qrCode;
    } catch (error) {
      if (!ref.mounted) return null;

      state = state.copyWith(isSaving: false, errorMessage: _mapError(error));

      return null;
    }
  }

  String _mapError(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    return 'Não foi possível processar a operação da mesa.';
  }
}
