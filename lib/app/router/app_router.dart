import 'package:dishmade_front/features/categories/presentation/pages/categories_page.dart';
import 'package:dishmade_front/features/orders/presentation/pages/orders_page.dart';
import 'package:dishmade_front/features/sales_history/presentation/pages/sales_history_page.dart';
import 'package:dishmade_front/features/tables/presentation/pages/tables_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/dishes/presentation/pages/dishes_page.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: [
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.dishes,
        builder: (context, state) => const DishesPage(),
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
        path: AppRoutes.salesHistory,
        builder: (context, state) => const SalesHistoryPage(),
      ),
    ],
  );
});
