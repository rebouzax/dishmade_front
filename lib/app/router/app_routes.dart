abstract final class AppRoutes {
  static const login = '/login';

  static const home = '/';

  static const dashboard = '/dashboard';

  static const adminClients = '/admin/clients';

  static const dishes = '/dishes';
  static const dishForm = '/dishes/form';

  static const categories = '/categories';

  static const tables = '/tables';

  static const orders = '/orders';

  static const kitchen = '/kitchen';

  static const salesHistory = '/sales-history';

  static const publicMenu = '/menu/:slug';

  static String publicMenuBySlug(String slug) => '/menu/$slug';
}
