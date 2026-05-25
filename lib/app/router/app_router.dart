import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/categories/presentation/pages/categories_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/dishes/domain/entities/dish.dart';
import '../../features/dishes/presentation/pages/dish_form_page.dart';
import '../../features/dishes/presentation/pages/dishes_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/kitchen/presentation/pages/kitchen_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/sales_history/presentation/pages/sales_history_page.dart';
import '../../features/tables/presentation/pages/tables_page.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
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
    ],
  );
});
