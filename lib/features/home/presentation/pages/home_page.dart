import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/viewmodels/auth_controller.dart';
import '../widgets/home_hero_card.dart';
import '../widgets/home_module_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<_HomeModule> modules = [
      _HomeModule(
        title: 'Dashboard',
        description:
            'Veja faturamento, pedidos entregues, ticket médio e pratos mais vendidos.',
        icon: Icons.dashboard_rounded,
        color: AppColors.primary,
        route: AppRoutes.dashboard,
      ),
      _HomeModule(
        title: 'Cardápio',
        description:
            'Gerencie pratos, preços, categorias e disponibilidade dos itens.',
        icon: Icons.restaurant_menu_rounded,
        color: AppColors.success,
        route: AppRoutes.dishes,
      ),
      _HomeModule(
        title: 'Categorias',
        description:
            'Organize o cardápio por grupos como bebidas, entradas e sobremesas.',
        icon: Icons.category_rounded,
        color: AppColors.warning,
        route: AppRoutes.categories,
      ),
      _HomeModule(
        title: 'Mesas',
        description:
            'Cadastre mesas, acompanhe ocupação e libere mesas manualmente.',
        icon: Icons.table_restaurant_rounded,
        color: AppColors.primaryDark,
        route: AppRoutes.tables,
      ),
      _HomeModule(
        title: 'Pedidos',
        description:
            'Abra pedidos, adicione itens, acompanhe status e cancele quando necessário.',
        icon: Icons.receipt_long_rounded,
        color: AppColors.primary,
        route: AppRoutes.orders,
      ),
      _HomeModule(
        title: 'Cozinha / KDS',
        description:
            'Acompanhe pedidos novos, em preparo e prontos para entrega.',
        icon: Icons.soup_kitchen_rounded,
        color: AppColors.danger,
        route: AppRoutes.kitchen,
      ),
      _HomeModule(
        title: 'Histórico de Vendas',
        description:
            'Consulte vendas entregues, itens vendidos e detalhes por período.',
        icon: Icons.payments_rounded,
        color: AppColors.success,
        route: AppRoutes.salesHistory,
      ),
      _HomeModule(
        title: 'Solicitações',
        description: 'Chamados de garçom, conta e ajuda enviados pelo QR Code.',
        icon: Icons.room_service_rounded,
        color: AppColors.success,
        route: AppRoutes.serviceRequests,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dishmade'),
        actions: [
          IconButton(
            tooltip: 'Dashboard',
            onPressed: () => context.push(AppRoutes.dashboard),
            icon: const Icon(Icons.dashboard_rounded),
          ),
          IconButton(
            tooltip: 'Sair',
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 18, 20, 10),
                    child: HomeHeroCard(),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 14, 20, 8),
                    child: _SectionHeader(
                      title: 'Módulos do sistema',
                      subtitle:
                          'Acesse rapidamente as áreas principais da operação.',
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final module = modules[index];

                      return HomeModuleCard(
                        title: module.title,
                        description: module.description,
                        icon: module.icon,
                        accentColor: module.color,
                        onTap: () => context.push(module.route),
                      );
                    }, childCount: modules.length),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: _getChildAspectRatio(
                        constraints.maxWidth,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  int _getCrossAxisCount(double width) {
    if (width >= 1200) return 4;
    if (width >= 900) return 3;
    if (width >= 600) return 2;
    return 1;
  }

  double _getChildAspectRatio(double width) {
    if (width >= 1200) return 1.35;
    if (width >= 900) return 1.25;
    if (width >= 600) return 1.25;
    return 1.65;
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _HomeModule {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  const _HomeModule({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}
