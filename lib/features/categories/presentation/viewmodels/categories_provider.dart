import 'package:dishmade_front/features/dishes/domain/entities/dish_category.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/usecases/get_categories_usecase.dart';

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return GetCategoriesUseCase(repository);
});

final activeCategoriesProvider = FutureProvider.autoDispose<List<DishCategory>>(
  (ref) async {
    final useCase = ref.watch(getCategoriesUseCaseProvider);

    final response = await useCase(
      isActive: true,
      pageNumber: 1,
      pageSize: 100,
    );

    return response.items;
  },
);
