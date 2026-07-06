import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import '../../../../core/pagination/paginated_response.dart';
import '../../domain/entities/dish.dart';
import '../../domain/entities/dish_option.dart';
import '../../domain/entities/dish_option_group.dart';
import '../../domain/repositories/dish_repository.dart';
import '../datasources/dish_remote_datasource.dart';
import '../dtos/create_dish_option_group_request.dart';
import '../dtos/create_dish_option_request.dart';
import '../dtos/create_dish_request.dart';
import '../dtos/update_dish_option_group_request.dart';
import '../dtos/update_dish_option_request.dart';
import '../dtos/update_dish_request.dart';

final dishRepositoryProvider = Provider<DishRepository>((ref) {
  final remoteDataSource = ref.watch(dishRemoteDataSourceProvider);
  return DishRepositoryImpl(remoteDataSource);
});

class DishRepositoryImpl implements DishRepository {
  final DishRemoteDataSource _remoteDataSource;

  const DishRepositoryImpl(this._remoteDataSource);

  @override
  Future<PaginatedResponse<Dish>> getDishes({
    String? search,
    String? categoryId,
    bool? isAvailable,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final response = await _remoteDataSource.getDishes(
      search: search,
      categoryId: categoryId,
      isAvailable: isAvailable,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    return PaginatedResponse<Dish>(
      items: response.items.map((dto) => dto.toEntity()).toList(),
      pageNumber: response.pageNumber,
      pageSize: response.pageSize,
      totalCount: response.totalCount,
      totalPages: response.totalPages,
      hasPreviousPage: response.hasPreviousPage,
      hasNextPage: response.hasNextPage,
    );
  }

  @override
  Future<String> createDish({
    required String name,
    required String description,
    required double price,
    required String categoryId,
  }) {
    return _remoteDataSource.createDish(
      CreateDishRequest(
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
      ),
    );
  }

  @override
  Future<void> updateDish({
    required String id,
    required String name,
    required String description,
    required double price,
    required String categoryId,
  }) {
    return _remoteDataSource.updateDish(
      id: id,
      request: UpdateDishRequest(
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
      ),
    );
  }

  @override
  Future<void> uploadDishImage({
    required String dishId,
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) {
    return _remoteDataSource.uploadDishImage(
      dishId: dishId,
      bytes: bytes,
      fileName: fileName,
      contentType: contentType,
    );
  }

  @override
  Future<Uint8List> getDishImageBytes({required String dishId}) {
    return _remoteDataSource.getDishImageBytes(dishId: dishId);
  }

  @override
  Future<void> deleteDishImage({required String dishId}) {
    return _remoteDataSource.deleteDishImage(dishId: dishId);
  }

  @override
  Future<List<DishOptionGroup>> getOptionGroups({
    required String dishId,
  }) async {
    final response = await _remoteDataSource.getOptionGroups(dishId: dishId);
    return response.map((group) => group.toEntity()).toList();
  }

  @override
  Future<DishOptionGroup> createOptionGroup({
    required String dishId,
    required String name,
    required bool isRequired,
    required int minSelection,
    required int maxSelection,
  }) async {
    final response = await _remoteDataSource.createOptionGroup(
      dishId: dishId,
      request: CreateDishOptionGroupRequest(
        name: name,
        isRequired: isRequired,
        minSelection: minSelection,
        maxSelection: maxSelection,
      ),
    );

    return response.toEntity();
  }

  @override
  Future<DishOption> createOption({
    required String dishId,
    required String optionGroupId,
    required String name,
    required double additionalPrice,
  }) async {
    final response = await _remoteDataSource.createOption(
      dishId: dishId,
      optionGroupId: optionGroupId,
      request: CreateDishOptionRequest(
        name: name,
        additionalPrice: additionalPrice,
      ),
    );

    return response.toEntity();
  }

  @override
  Future<DishOptionGroup> updateOptionGroup({
    required String dishId,
    required String groupId,
    required String name,
    required bool isRequired,
    required int minSelection,
    required int maxSelection,
  }) async {
    final response = await _remoteDataSource.updateOptionGroup(
      dishId: dishId,
      groupId: groupId,
      request: UpdateDishOptionGroupRequest(
        name: name,
        isRequired: isRequired,
        minSelection: minSelection,
        maxSelection: maxSelection,
      ),
    );

    return response.toEntity();
  }

  @override
  Future<void> deleteOptionGroup({
    required String dishId,
    required String groupId,
  }) {
    return _remoteDataSource.deleteOptionGroup(
      dishId: dishId,
      groupId: groupId,
    );
  }

  @override
  Future<DishOption> updateOption({
    required String dishId,
    required String groupId,
    required String optionId,
    required String name,
    required double additionalPrice,
  }) async {
    final response = await _remoteDataSource.updateOption(
      dishId: dishId,
      groupId: groupId,
      optionId: optionId,
      request: UpdateDishOptionRequest(
        name: name,
        additionalPrice: additionalPrice,
      ),
    );

    return response.toEntity();
  }

  @override
  Future<DishOption> setOptionAvailability({
    required String dishId,
    required String groupId,
    required String optionId,
    required bool isAvailable,
  }) async {
    final response = await _remoteDataSource.setOptionAvailability(
      dishId: dishId,
      groupId: groupId,
      optionId: optionId,
      isAvailable: isAvailable,
    );

    return response.toEntity();
  }

  @override
  Future<void> deleteOption({
    required String dishId,
    required String groupId,
    required String optionId,
  }) {
    return _remoteDataSource.deleteOption(
      dishId: dishId,
      groupId: groupId,
      optionId: optionId,
    );
  }
}
