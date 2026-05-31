import '../../domain/entities/public_dish.dart';
import '../../domain/entities/public_menu.dart';

const _unset = Object();

class PublicMenuState {
  final PublicMenu? menu;
  final bool isLoading;
  final String? errorMessage;
  final String? selectedCategoryId;

  const PublicMenuState({
    this.menu,
    this.isLoading = false,
    this.errorMessage,
    this.selectedCategoryId,
  });

  List<PublicDish> get visibleDishes {
    final currentMenu = menu;

    if (currentMenu == null) {
      return const [];
    }

    if (selectedCategoryId == null) {
      return currentMenu.allDishes;
    }

    for (final category in currentMenu.categories) {
      if (category.id == selectedCategoryId) {
        return category.dishes;
      }
    }

    return const [];
  }

  PublicMenuState copyWith({
    PublicMenu? menu,
    bool? isLoading,
    Object? errorMessage = _unset,
    Object? selectedCategoryId = _unset,
  }) {
    return PublicMenuState(
      menu: menu ?? this.menu,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      selectedCategoryId: selectedCategoryId == _unset
          ? this.selectedCategoryId
          : selectedCategoryId as String?,
    );
  }
}
