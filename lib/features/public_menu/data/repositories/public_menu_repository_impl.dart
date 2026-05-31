import 'package:dishmade_front/features/public_menu/domain/repositories/public_menu_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/public_menu.dart';
import '../datasources/public_menu_remote_datasource.dart';

final publicMenuRepositoryProvider = Provider<PublicMenuRepository>((ref) {
  final remoteDataSource = ref.watch(publicMenuRemoteDataSourceProvider);
  return PublicMenuRepositoryImpl(remoteDataSource);
});

class PublicMenuRepositoryImpl implements PublicMenuRepository {
  final PublicMenuRemoteDataSource _remoteDataSource;

  const PublicMenuRepositoryImpl(this._remoteDataSource);

  @override
  Future<PublicMenu> getMenu(String slug) async {
    final response = await _remoteDataSource.getMenu(slug);
    return response.toEntity();
  }
}
