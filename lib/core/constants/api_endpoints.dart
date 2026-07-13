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

  static const publicOrdersOpenOrCreate = '/api/public/orders/open-or-create';

  static String publicCurrentOrderByTable({
    required String slug,
    required int tableNumber,
  }) => '/api/public/restaurants/$slug/tables/$tableNumber/current-order';

  static String publicOrderById(String id) => '/api/public/orders/$id';

  static String publicOrderItems(String id) => '/api/public/orders/$id/items';

  static const serviceRequests = '/api/service-requests';
  static const publicServiceRequests = '/api/public/service-requests';

  static String serviceRequestById(String id) => '/api/service-requests/$id';
  static String startServiceRequest(String id) =>
      '/api/service-requests/$id/start';
  static String resolveServiceRequest(String id) =>
      '/api/service-requests/$id/resolve';
  static String cancelServiceRequest(String id) =>
      '/api/service-requests/$id/cancel';

  static String enableTableMenuQrCode(String id) =>
      '/api/tables/$id/menu-qr-code/enable';

  static String disableTableMenuQrCode(String id) =>
      '/api/tables/$id/menu-qr-code/disable';

  static String tableMenuQrCode(String id) => '/api/tables/$id/menu-qr-code';

  static String tableMenuQrCodeImage(String id) =>
      '/api/tables/$id/menu-qr-code/image';
  static String dishOptionGroups(String dishId) =>
      '/api/dishes/$dishId/option-groups';

  static String dishOptionGroupOptions({
    required String dishId,
    required String optionGroupId,
  }) => '/api/dishes/$dishId/option-groups/$optionGroupId/options';

  static String dishOptionGroupById({
    required String dishId,
    required String groupId,
  }) => '/api/dishes/$dishId/option-groups/$groupId';

  static String dishOptionById({
    required String dishId,
    required String groupId,
    required String optionId,
  }) => '/api/dishes/$dishId/option-groups/$groupId/options/$optionId';

  static String dishOptionAvailable({
    required String dishId,
    required String groupId,
    required String optionId,
  }) =>
      '/api/dishes/$dishId/option-groups/$groupId/options/$optionId/available';

  static String dishOptionUnavailable({
    required String dishId,
    required String groupId,
    required String optionId,
  }) =>
      '/api/dishes/$dishId/option-groups/$groupId/options/$optionId/unavailable';

  static String closeOrderAccount(String id) => '/api/orders/$id/close';

  static String orderPayments(String id) => '/api/orders/$id/payments';

  static String orderReceipt(String id) => '/api/orders/$id/receipt';
}
