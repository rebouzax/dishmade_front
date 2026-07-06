import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/service_requests/presentation/pages/service_requests_page.dart';
import '../../features/admin_clients/presentation/pages/admin_clients_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/viewmodels/auth_controller.dart';
import '../../features/categories/presentation/pages/categories_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/dishes/domain/entities/dish.dart';
import '../../features/dishes/presentation/pages/dish_form_page.dart';
import '../../features/dishes/presentation/pages/dish_options_page.dart';
import '../../features/dishes/presentation/pages/dishes_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/kitchen/presentation/pages/kitchen_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/public_menu/presentation/pages/public_menu_page.dart';
import '../../features/sales_history/presentation/pages/sales_history_page.dart';
import '../../features/tables/presentation/pages/tables_page.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final location = state.uri.path;

      final isPublicRoute = location.startsWith('/menu/');

      if (isPublicRoute) {
        return null;
      }

      if (authState.isLoading) {
        return null;
      }

      final session = authState.session;
      final isLoginRoute = location == AppRoutes.login;
      final isAdminRoute = location.startsWith('/admin');

      if (session == null || !session.isValid) {
        return isLoginRoute ? null : AppRoutes.login;
      }

      final user = session.user;

      if (isLoginRoute) {
        if (user.isPlatformAdmin) {
          return AppRoutes.adminClients;
        }

        return AppRoutes.home;
      }

      if (user.isPlatformAdmin && !isAdminRoute) {
        return AppRoutes.adminClients;
      }

      if (user.isClient && isAdminRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.publicMenu,
        builder: (context, state) {
          final slug = state.pathParameters['slug'] ?? '';
          final tableParam = state.uri.queryParameters['table'];
          final tableNumber = int.tryParse(tableParam ?? '');

          return PublicMenuPage(slug: slug, initialTableNumber: tableNumber);
        },
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.adminClients,
        builder: (context, state) => const AdminClientsPage(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.dishes,
        builder: (context, state) => const DishesPage(),
      ),
      GoRoute(
        path: AppRoutes.dishForm,
        builder: (context, state) {
          final dish = state.extra is Dish ? state.extra as Dish : null;

          return DishFormPage(dish: dish);
        },
      ),
      GoRoute(
        path: AppRoutes.dishOptions,
        builder: (context, state) {
          final dish = state.extra as Dish;
          return DishOptionsPage(dish: dish);
        },
      ),
      GoRoute(
        path: AppRoutes.categories,
        builder: (context, state) => const CategoriesPage(),
      ),
      GoRoute(
        path: AppRoutes.tables,
        builder: (context, state) => const TablesPage(),
      ),
      GoRoute(
        path: AppRoutes.orders,
        builder: (context, state) => const OrdersPage(),
      ),
      GoRoute(
        path: AppRoutes.kitchen,
        builder: (context, state) => const KitchenPage(),
      ),
      GoRoute(
        path: AppRoutes.salesHistory,
        builder: (context, state) => const SalesHistoryPage(),
      ),
      GoRoute(
        path: AppRoutes.serviceRequests,
        builder: (context, state) => const ServiceRequestsPage(),
      ),
    ],
  );
});
