import 'dart:typed_data';

import '../../../../core/pagination/paginated_response.dart';
import '../entities/dish.dart';
import '../entities/dish_option.dart';
import '../entities/dish_option_group.dart';

abstract interface class DishRepository {
  Future<PaginatedResponse<Dish>> getDishes({
    String? search,
    String? categoryId,
    bool? isAvailable,
    int pageNumber = 1,
    int pageSize = 20,
  });

  Future<String> createDish({
    required String name,
    required String description,
    required double price,
    required String categoryId,
  });

  Future<void> updateDish({
    required String id,
    required String name,
    required String description,
    required double price,
    required String categoryId,
  });

  Future<void> uploadDishImage({
    required String dishId,
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  });

  Future<Uint8List> getDishImageBytes({required String dishId});

  Future<void> deleteDishImage({required String dishId});

  Future<List<DishOptionGroup>> getOptionGroups({required String dishId});

  Future<DishOptionGroup> createOptionGroup({
    required String dishId,
    required String name,
    required bool isRequired,
    required int minSelection,
    required int maxSelection,
  });

  Future<DishOption> createOption({
    required String dishId,
    required String optionGroupId,
    required String name,
    required double additionalPrice,
  });

  Future<DishOptionGroup> updateOptionGroup({
    required String dishId,
    required String groupId,
    required String name,
    required bool isRequired,
    required int minSelection,
    required int maxSelection,
  });

  Future<void> deleteOptionGroup({
    required String dishId,
    required String groupId,
  });

  Future<DishOption> updateOption({
    required String dishId,
    required String groupId,
    required String optionId,
    required String name,
    required double additionalPrice,
  });

  Future<DishOption> setOptionAvailability({
    required String dishId,
    required String groupId,
    required String optionId,
    required bool isAvailable,
  });

  Future<void> deleteOption({
    required String dishId,
    required String groupId,
    required String optionId,
  });
}
