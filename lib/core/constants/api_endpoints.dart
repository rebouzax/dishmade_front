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

  static String tableById(String id) => '/api/tables/$id';
  static String occupyTable(String id) => '/api/tables/$id/occupy';
  static String releaseTable(String id) => '/api/tables/$id/release';

  static String orderById(String id) => '/api/orders/$id';
  static String addOrderItem(String orderId) => '/api/orders/$orderId/items';
  static String updateOrderStatus(String orderId) =>
      '/api/orders/$orderId/status';
  static String cancelOrder(String orderId) => '/api/orders/$orderId/cancel';
}
