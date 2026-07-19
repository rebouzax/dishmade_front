import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/public_dish.dart';
import '../../domain/entities/public_order.dart';
import '../viewmodels/public_menu_viewmodel.dart';
import '../viewmodels/public_order_viewmodel.dart';
import '../widgets/add_public_dish_dialog.dart';
import '../widgets/public_category_tabs.dart';
import '../widgets/public_dish_card.dart';
import '../widgets/public_order_bottom_bar.dart';
import '../widgets/public_order_details_sheet.dart';
import '../../../../features/service_requests/presentation/viewmodels/public_service_request_viewmodel.dart';
import '../../../../features/service_requests/presentation/widgets/service_request_dialog.dart';

class PublicMenuPage extends ConsumerStatefulWidget {
  final String slug;
  final int? initialTableNumber;

  const PublicMenuPage({
    super.key,
    required this.slug,
    this.initialTableNumber,
  });

  @override
  ConsumerState<PublicMenuPage> createState() => _PublicMenuPageState();
}

class _PublicMenuPageState extends ConsumerState<PublicMenuPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(publicMenuViewModelProvider.notifier).loadMenu(widget.slug);

      ref
          .read(publicOrderViewModelProvider.notifier)
          .restoreOrder(
            slug: widget.slug,
            tableNumber: widget.initialTableNumber,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(publicMenuViewModelProvider);
    final viewModel = ref.read(publicMenuViewModelProvider.notifier);
    final menu = state.menu;

    final orderState = ref.watch(publicOrderViewModelProvider);
    final serviceRequestState = ref.watch(
      publicServiceRequestViewModelProvider,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          if (widget.initialTableNumber != null)
            IconButton(
              tooltip: menu == null
                  ? 'Carregando atendimento'
                  : menu.acceptsWaiterCall
                  ? 'Chamar garçom'
                  : 'Chamada de garçom indisponível',
              onPressed:
                  menu == null ||
                      !menu.acceptsWaiterCall ||
                      serviceRequestState.isSending
                  ? null
                  : _openServiceRequest,
              icon: const Icon(Icons.support_agent_rounded),
            ),
        ],
      ),
      bottomNavigationBar: orderState.order == null
          ? null
          : PublicOrderBottomBar(
              order: orderState.order!,
              isSaving: orderState.isSaving,
              onViewOrder: () => _openOrderDetails(orderState.order!),
            ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => viewModel.loadMenu(widget.slug),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (state.isLoading && menu == null)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.errorMessage != null && menu == null)
                    SliverFillRemaining(
                      child: _ErrorState(
                        message: state.errorMessage!,
                        onRetry: () => viewModel.loadMenu(widget.slug),
                      ),
                    )
                  else if (menu == null)
                    const SliverFillRemaining(
                      child: _ErrorState(message: 'Cardápio não encontrado.'),
                    )
                  else ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                        child: _Header(
                          restaurantName: menu.restaurantName,
                          dishCount: menu.allDishes.length,
                        ),
                      ),
                    ),
                    if (!menu.acceptsQrCodeOrders)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                          child: _QrCodeOrdersDisabledBanner(),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                        child: PublicCategoryTabs(
                          categories: menu.categories,
                          selectedCategoryId: state.selectedCategoryId,
                          onChanged: viewModel.selectCategory,
                        ),
                      ),
                    ),
                    if (state.visibleDishes.isEmpty)
                      const SliverFillRemaining(child: _EmptyState())
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final dish = state.visibleDishes[index];

                            return PublicDishCard(
                              dish: dish,
                              onAdd: () {
                                if (!menu.acceptsQrCodeOrders) {
                                  _showQrCodeOrdersDisabledMessage();
                                  return;
                                }

                                _handleAddDish(dish);
                              },
                            );
                          }, childCount: state.visibleDishes.length),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
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
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  int _getCrossAxisCount(double width) {
    if (width >= 1100) return 4;
    if (width >= 800) return 3;
    if (width >= 560) return 2;
    return 1;
  }

  double _getChildAspectRatio(double width) {
    if (width >= 1100) return 0.78;
    if (width >= 800) return 0.76;
    if (width >= 560) return 0.72;
    return 0.88;
  }

  Future<void> _handleAddDish(PublicDish dish) async {
    final menu = ref.read(publicMenuViewModelProvider).menu;

    if (menu != null && !menu.acceptsQrCodeOrders) {
      _showQrCodeOrdersDisabledMessage();
      return;
    }

    final orderViewModel = ref.read(publicOrderViewModelProvider.notifier);
    final currentOrder = ref.read(publicOrderViewModelProvider).order;

    if (currentOrder == null) {
      final tableNumber = widget.initialTableNumber ?? await _askTableNumber();

      if (tableNumber == null) return;

      final created = await orderViewModel.createOrder(
        restaurantSlug: widget.slug,
        tableNumber: tableNumber,
      );

      if (!mounted || !created) {
        _showPublicOrderError();
        return;
      }
    }

    final result = await showDialog<AddPublicDishDialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AddPublicDishDialog(dish: dish);
      },
    );

    if (result == null) return;

    final success = await orderViewModel.addItem(
      dishId: dish.id,
      quantity: result.quantity,
      notes: result.notes,
      optionIds: result.optionIds,
    );

    if (!mounted || !success) {
      _showPublicOrderError();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${dish.name} adicionado ao pedido.')),
    );
  }

  Future<int?> _askTableNumber() async {
    final controller = TextEditingController();

    final result = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Informe sua mesa'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Número da mesa',
              hintText: 'Ex: 2',
              prefixIcon: Icon(Icons.table_restaurant_rounded),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final tableNumber = int.tryParse(controller.text.trim());

                if (tableNumber == null || tableNumber <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Informe um número válido.')),
                  );
                  return;
                }

                Navigator.of(context).pop(tableNumber);
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    return result;
  }

  Future<void> _openOrderDetails(PublicOrder order) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return PublicOrderDetailsSheet(
          order: order,
          onRefresh: () {
            ref.read(publicOrderViewModelProvider.notifier).refreshOrder();
          },
        );
      },
    );
  }

  Future<void> _openServiceRequest() async {
    final menu = ref.read(publicMenuViewModelProvider).menu;

    if (menu != null && !menu.acceptsWaiterCall) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Este restaurante não aceita chamadas de garçom pelo QR Code no momento.',
          ),
        ),
      );
      return;
    }

    final tableNumber = widget.initialTableNumber ?? await _askTableNumber();

    if (!mounted || tableNumber == null) return;

    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ServiceRequestDialog(
          restaurantSlug: widget.slug,
          tableNumber: tableNumber,
        );
      },
    );
  }

  void _showPublicOrderError() {
    final message =
        ref.read(publicOrderViewModelProvider).errorMessage ??
        'Não foi possível processar o pedido.';

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showQrCodeOrdersDisabledMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Este restaurante não aceita pedidos pelo QR Code no momento.',
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String restaurantName;
  final int dishCount;

  const _Header({required this.restaurantName, required this.dishCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.restaurant_menu_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurantName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$dishCount itens disponíveis no cardápio',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.88),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QrCodeOrdersDisabledBanner extends StatelessWidget {
  const _QrCodeOrdersDisabledBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withOpacity(0.25)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.warning),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pedidos pelo QR Code estão desativados no momento. '
              'O cardápio está disponível apenas para consulta.',
              style: TextStyle(
                color: AppColors.warning,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorState({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 42,
              color: AppColors.danger,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                child: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
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
        child: Text(
          'Nenhum prato disponível nesta categoria.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
