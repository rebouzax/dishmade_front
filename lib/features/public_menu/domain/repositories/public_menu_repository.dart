import '../entities/public_menu.dart';

abstract interface class PublicMenuRepository {
  Future<PublicMenu> getMenu(String slug);
}
