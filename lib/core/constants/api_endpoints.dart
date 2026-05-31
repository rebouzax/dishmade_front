abstract final class ApiEndpoints {
  static const login = '/api/auth/login';

  static const adminClients = '/api/admin/clients';

  static const categories = '/api/categories';
  static const dishes = '/api/dishes';
  static const tables = '/api/tables';
  static const orders = '/api/orders';
  static const salesHistory = '/api/sales-history';
  static const dashboard = '/api/dashboard';

  static String dishById(String id) => '/api/dishes/$id';
  static String dishImage(String id) => '/api/dishes/$id/image';

  static String tableById(String id) => '/api/tables/$id';
  static String occupyTable(String id) => '/api/tables/$id/occupy';
  static String releaseTable(String id) => '/api/tables/$id/release';

  static String orderById(String id) => '/api/orders/$id';
  static String addOrderItem(String orderId) => '/api/orders/$orderId/items';
  static String updateOrderStatus(String orderId) =>
      '/api/orders/$orderId/status';
  static String cancelOrder(String orderId) => '/api/orders/$orderId/cancel';

  static const publicPrefix = '/api/public';

  static String publicMenu(String slug) => '/api/public/restaurants/$slug/menu';

  static String publicCategories(String slug) =>
      '/api/public/restaurants/$slug/categories';

  static String publicDishes(String slug) =>
      '/api/public/restaurants/$slug/dishes';

  static String publicDishImage(String dishId) =>
      '/api/public/dishes/$dishId/image';

  static String publicQrCode(String slug) =>
      '/api/public/restaurants/$slug/qr-code';

  static const publicOrders = '/api/public/orders';

  static String publicOrderById(String id) => '/api/public/orders/$id';

  static String publicOrderItems(String id) => '/api/public/orders/$id/items';
}
