import '../../domain/entities/dish_option_group.dart';

const _unset = Object();

class DishOptionsState {
  final List<DishOptionGroup> groups;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  const DishOptionsState({
    this.groups = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  DishOptionsState copyWith({
    List<DishOptionGroup>? groups,
    bool? isLoading,
    bool? isSaving,
    Object? errorMessage = _unset,
  }) {
    return DishOptionsState(
      groups: groups ?? this.groups,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
