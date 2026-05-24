class DishFormState {
  final bool isSaving;
  final String? errorMessage;

  const DishFormState({this.isSaving = false, this.errorMessage});

  DishFormState copyWith({bool? isSaving, String? errorMessage}) {
    return DishFormState(
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}
