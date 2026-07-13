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
  static String enableTableMenuQrCode(String id) =>
      '/api/tables/$id/menu-qr-code/enable';

  static String disableTableMenuQrCode(String id) =>
      '/api/tables/$id/menu-qr-code/disable';

  static String tableMenuQrCode(String id) => '/api/tables/$id/menu-qr-code';

  static String tableMenuQrCodeImage(String id) =>
      '/api/tables/$id/menu-qr-code/image';

  static const dishOptions = '/dishes/options';
  static const serviceRequests = '/service-requests';
  static const orderCheckout = '/orders/checkout';
}
