import 'package:dishmade_front/app/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/realtime/kitchen_realtime_controller.dart';
import '../../../orders/domain/entities/order_status.dart';
import '../../../orders/domain/entities/restaurant_order.dart';
import '../viewmodels/kitchen_viewmodel.dart';
import '../widgets/kitchen_column.dart';

class KitchenPage extends ConsumerStatefulWidget {
  const KitchenPage({super.key});

  @override
  ConsumerState<KitchenPage> createState() => _KitchenPageState();
}

class _KitchenPageState extends ConsumerState<KitchenPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(kitchenViewModelProvider.notifier).refresh();
      ref.read(kitchenRealtimeControllerProvider.notifier).connect();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kitchenViewModelProvider);
    final viewModel = ref.read(kitchenViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cozinha / KDS'),
        actions: [
          IconButton(
            tooltip: 'Home',
            onPressed: () => context.go(AppRoutes.home),
            icon: const Icon(Icons.home_rounded),
          ),
          IconButton(
            tooltip: 'Atualizar',
            onPressed: state.isLoading ? null : viewModel.refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: viewModel.refresh,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(
                        totalOrders: state.totalOrders,
                        lastUpdatedAt: state.lastUpdatedAt,
                      ),
                      if (state.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        _ErrorBanner(message: state.errorMessage!),
                      ],
                      const SizedBox(height: 18),
                      if (state.isLoading && state.isEmpty)
                        const SizedBox(
                          height: 360,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: KitchenColumn(
                                title: 'Novos',
                                description: 'Pedidos recém-criados',
                                icon: Icons.fiber_new_rounded,
                                accentColor: AppColors.warning,
                                orders: state.createdOrders,
                                emptyMessage: 'Nenhum pedido novo.',
                                processingOrderId: state.processingOrderId,
                                onAdvance: (order) =>
                                    _advanceOrder(context, ref, order),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: KitchenColumn(
                                title: 'Em preparo',
                                description: 'Pedidos sendo preparados',
                                icon: Icons.soup_kitchen_rounded,
                                accentColor: AppColors.primary,
                                orders: state.inPreparationOrders,
                                emptyMessage: 'Nenhum pedido em preparo.',
                                processingOrderId: state.processingOrderId,
                                onAdvance: (order) =>
                                    _advanceOrder(context, ref, order),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: KitchenColumn(
                                title: 'Prontos',
                                description: 'Aguardando entrega',
                                icon: Icons.check_circle_rounded,
                                accentColor: AppColors.success,
                                orders: state.readyOrders,
                                emptyMessage: 'Nenhum pedido pronto.',
                                processingOrderId: state.processingOrderId,
                                onAdvance: (order) =>
                                    _advanceOrder(context, ref, order),
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            KitchenColumn(
                              title: 'Novos',
                              description: 'Pedidos recém-criados',
                              icon: Icons.fiber_new_rounded,
                              accentColor: AppColors.warning,
                              orders: state.createdOrders,
                              emptyMessage: 'Nenhum pedido novo.',
                              processingOrderId: state.processingOrderId,
                              onAdvance: (order) =>
                                  _advanceOrder(context, ref, order),
                            ),
                            const SizedBox(height: 14),
                            KitchenColumn(
                              title: 'Em preparo',
                              description: 'Pedidos sendo preparados',
                              icon: Icons.soup_kitchen_rounded,
                              accentColor: AppColors.primary,
                              orders: state.inPreparationOrders,
                              emptyMessage: 'Nenhum pedido em preparo.',
                              processingOrderId: state.processingOrderId,
                              onAdvance: (order) =>
                                  _advanceOrder(context, ref, order),
                            ),
                            const SizedBox(height: 14),
                            KitchenColumn(
                              title: 'Prontos',
                              description: 'Aguardando entrega',
                              icon: Icons.check_circle_rounded,
                              accentColor: AppColors.success,
                              orders: state.readyOrders,
                              emptyMessage: 'Nenhum pedido pronto.',
                              processingOrderId: state.processingOrderId,
                              onAdvance: (order) =>
                                  _advanceOrder(context, ref, order),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _advanceOrder(
    BuildContext context,
    WidgetRef ref,
    RestaurantOrder order,
  ) async {
    final nextStatus = order.status.nextStatus;

    if (nextStatus == null) {
      return;
    }

    final success = await ref
        .read(kitchenViewModelProvider.notifier)
        .advanceOrder(order);

    if (!context.mounted || !success) return;

    final message = nextStatus == OrderStatus.delivered
        ? 'Pedido entregue. A mesa foi liberada.'
        : 'Pedido atualizado para "${nextStatus.label}".';

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Header extends StatelessWidget {
  final int totalOrders;
  final DateTime? lastUpdatedAt;

  const _Header({required this.totalOrders, required this.lastUpdatedAt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastUpdateText = lastUpdatedAt == null
        ? 'Ainda não atualizado'
        : 'Atualizado às ${TimeOfDay.fromDateTime(lastUpdatedAt!).format(context)}';

    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.soup_kitchen_rounded,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Painel da Cozinha',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalOrders pedidos em operação • $lastUpdateText',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.danger.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
