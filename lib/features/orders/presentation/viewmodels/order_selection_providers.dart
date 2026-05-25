import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dishes/data/repositories/dish_repository_impl.dart';
import '../../../dishes/domain/entities/dish.dart';
import '../../../dishes/domain/usecases/get_dishes_usecase.dart';
import '../../../tables/data/repositories/table_repository_impl.dart';
import '../../../tables/domain/entities/restaurant_table.dart';
import '../../../tables/domain/usecases/get_tables_usecase.dart';

final freeTablesForOrderProvider =
    FutureProvider.autoDispose<List<RestaurantTable>>((ref) async {
      final repository = ref.watch(tableRepositoryProvider);
      final useCase = GetTablesUseCase(repository);

      final response = await useCase(
        isOccupied: false,
        pageNumber: 1,
        pageSize: 100,
      );

      return response.items;
    });

final availableDishesForOrderProvider = FutureProvider.autoDispose<List<Dish>>((
  ref,
) async {
  final repository = ref.watch(dishRepositoryProvider);
  final useCase = GetDishesUseCase(repository);

  final response = await useCase(
    isAvailable: true,
    pageNumber: 1,
    pageSize: 100,
  );

  return response.items;
});
