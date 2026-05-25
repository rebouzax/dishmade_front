import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/restaurant_order.dart';
import '../viewmodels/order_selection_providers.dart';
import '../viewmodels/orders_viewmodel.dart';
import '../widgets/order_card.dart';

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ordersViewModelProvider);
    final viewModel = ref.read(ordersViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        actions: [
          IconButton(
            tooltip: 'Histórico de vendas',
            onPressed: () => context.push(AppRoutes.salesHistory),
            icon: const Icon(Icons.payments_rounded),
          ),
          IconButton(
            tooltip: 'Cozinha/KDS',
            onPressed: () => context.push(AppRoutes.kitchen),
            icon: const Icon(Icons.soup_kitchen_rounded),
          ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: state.isSaving
            ? null
            : () => _openCreateOrderDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo pedido'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: viewModel.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(
                        totalCount: state.totalCount,
                        orders: state.orders,
                      ),
                      const SizedBox(height: 16),
                      _StatusFilters(
                        selectedStatus: state.status,
                        onChanged: viewModel.setStatusFilter,
                      ),
                      if (state.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        _ErrorBanner(message: state.errorMessage!),
                      ],
                    ],
                  ),
                ),
              ),
              if (state.isLoading && state.orders.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.orders.isEmpty)
                const SliverFillRemaining(child: _EmptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  sliver: SliverList.separated(
                    itemCount: state.orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = state.orders[index];

                      return OrderCard(
                        order: order,
                        onAddItem: () =>
                            _openAddItemDialog(context, ref, order),
                        onNextStatus: order.status.nextStatus == null
                            ? null
                            : () => _confirmUpdateStatus(
                                context,
                                ref,
                                order,
                                order.status.nextStatus!,
                              ),
                        onCancel: order.status.canCancel
                            ? () => _confirmCancelOrder(context, ref, order)
                            : null,
                      );
                    },
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                  child: _LoadMoreButton(
                    isLoadingMore: state.isLoadingMore,
                    hasNextPage: state.hasNextPage,
                    onPressed: viewModel.loadMore,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openCreateOrderDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    ref.invalidate(freeTablesForOrderProvider);

    String? selectedTableId;

    final tableId = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return Consumer(
          builder: (context, ref, _) {
            final tablesAsync = ref.watch(freeTablesForOrderProvider);

            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: const Text('Novo pedido'),
                  content: tablesAsync.when(
                    data: (tables) {
                      if (tables.isEmpty) {
                        return const Text(
                          'Nenhuma mesa livre encontrada. Libere ou cadastre uma mesa antes de criar o pedido.',
                        );
                      }

                      return DropdownButtonFormField<String>(
                        value: selectedTableId,
                        decoration: const InputDecoration(
                          labelText: 'Mesa livre',
                          prefixIcon: Icon(Icons.table_restaurant_rounded),
                        ),
                        items: tables.map((table) {
                          return DropdownMenuItem<String>(
                            value: table.id,
                            child: Text('Mesa ${table.number}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTableId = value;
                          });
                        },
                      );
                    },
                    loading: () {
                      return const SizedBox(
                        height: 80,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    error: (_, __) {
                      return const Text(
                        'Não foi possível carregar mesas livres.',
                      );
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: selectedTableId == null
                          ? null
                          : () {
                              Navigator.of(dialogContext).pop(selectedTableId);
                            },
                      child: const Text('Criar pedido'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );

    if (tableId == null) return;

    final success = await ref
        .read(ordersViewModelProvider.notifier)
        .createOrder(tableId);

    if (!context.mounted || !success) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Pedido criado com sucesso.')));
  }

  Future<void> _openAddItemDialog(
    BuildContext context,
    WidgetRef ref,
    RestaurantOrder order,
  ) async {
    ref.invalidate(availableDishesForOrderProvider);

    String? selectedDishId;
    final quantityController = TextEditingController(text: '1');

    final result = await showDialog<_AddItemResult>(
      context: context,
      builder: (dialogContext) {
        return Consumer(
          builder: (context, ref, _) {
            final dishesAsync = ref.watch(availableDishesForOrderProvider);

            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text('Adicionar item - Mesa ${order.tableNumber}'),
                  content: SizedBox(
                    width: 520,
                    child: dishesAsync.when(
                      data: (dishes) {
                        if (dishes.isEmpty) {
                          return const Text(
                            'Nenhum prato disponível encontrado.',
                          );
                        }

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DropdownButtonFormField<String>(
                              value: selectedDishId,
                              decoration: const InputDecoration(
                                labelText: 'Prato',
                                prefixIcon: Icon(Icons.restaurant_menu_rounded),
                              ),
                              items: dishes.map((dish) {
                                return DropdownMenuItem<String>(
                                  value: dish.id,
                                  child: Text(
                                    '${dish.name} - ${CurrencyFormatter.format(dish.price)}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedDishId = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: quantityController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Quantidade',
                                prefixIcon: Icon(Icons.numbers_rounded),
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () {
                        return const SizedBox(
                          height: 100,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      error: (_, __) {
                        return const Text(
                          'Não foi possível carregar os pratos disponíveis.',
                        );
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: selectedDishId == null
                          ? null
                          : () {
                              final quantity = int.tryParse(
                                quantityController.text.trim(),
                              );

                              if (quantity == null || quantity <= 0) {
                                return;
                              }

                              Navigator.of(dialogContext).pop(
                                _AddItemResult(
                                  dishId: selectedDishId!,
                                  quantity: quantity,
                                ),
                              );
                            },
                      child: const Text('Adicionar'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );

    quantityController.dispose();

    if (result == null) return;

    final success = await ref
        .read(ordersViewModelProvider.notifier)
        .addItem(
          orderId: order.id,
          dishId: result.dishId,
          quantity: result.quantity,
        );

    if (!context.mounted || !success) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Item adicionado ao pedido.')));
  }

  Future<void> _confirmUpdateStatus(
    BuildContext context,
    WidgetRef ref,
    RestaurantOrder order,
    OrderStatus nextStatus,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Atualizar status'),
          content: Text(
            'Deseja alterar o pedido da mesa ${order.tableNumber} para "${nextStatus.label}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final success = await ref
        .read(ordersViewModelProvider.notifier)
        .updateStatus(orderId: order.id, status: nextStatus);

    if (!context.mounted || !success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Status atualizado com sucesso.')),
    );
  }

  Future<void> _confirmCancelOrder(
    BuildContext context,
    WidgetRef ref,
    RestaurantOrder order,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancelar pedido'),
          content: Text(
            'Deseja cancelar o pedido da mesa ${order.tableNumber}? A mesa será liberada.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Voltar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Cancelar pedido'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final success = await ref
        .read(ordersViewModelProvider.notifier)
        .cancelOrder(order.id);

    if (!context.mounted || !success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pedido cancelado com sucesso.')),
    );
  }
}

class _AddItemResult {
  final String dishId;
  final int quantity;

  const _AddItemResult({required this.dishId, required this.quantity});
}

class _Header extends StatelessWidget {
  final int totalCount;
  final List<RestaurantOrder> orders;

  const _Header({required this.totalCount, required this.orders});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalOpen = orders
        .where(
          (order) =>
              order.status != OrderStatus.delivered &&
              order.status != OrderStatus.canceled,
        )
        .length;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pedidos',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalCount pedidos encontrados • $totalOpen em aberto',
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

class _StatusFilters extends StatelessWidget {
  final OrderStatus? selectedStatus;
  final ValueChanged<OrderStatus?> onChanged;

  const _StatusFilters({required this.selectedStatus, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Todos'),
              selected: selectedStatus == null,
              onSelected: (_) => onChanged(null),
            ),
          ),
          ...OrderStatus.values.map(
            (status) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(status.label),
                selected: selectedStatus == status,
                onSelected: (_) => onChanged(status),
              ),
            ),
          ),
        ],
      ),
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

class _LoadMoreButton extends StatelessWidget {
  final bool isLoadingMore;
  final bool hasNextPage;
  final VoidCallback onPressed;

  const _LoadMoreButton({
    required this.isLoadingMore,
    required this.hasNextPage,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasNextPage) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: isLoadingMore ? null : onPressed,
        child: isLoadingMore
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Carregar mais'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('Nenhum pedido encontrado.', textAlign: TextAlign.center),
      ),
    );
  }
}
