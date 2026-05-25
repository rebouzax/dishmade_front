import 'package:dishmade_front/app/router/app_routes.dart';
import 'package:dishmade_front/features/sales_history/presentation/viewmodels/sales_history_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../viewmodels/sales_history_viewmodel.dart';
import '../widgets/sale_history_card.dart';

class SalesHistoryPage extends ConsumerWidget {
  const SalesHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(salesHistoryViewModelProvider);
    final viewModel = ref.read(salesHistoryViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Vendas'),
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
                        startDate: state.startDate,
                        endDate: state.endDate,
                        onSelectDateRange: () {
                          _selectDateRange(context, viewModel, state);
                        },
                        onClearDateRange:
                            state.startDate == null && state.endDate == null
                            ? null
                            : viewModel.clearDateRange,
                      ),
                      const SizedBox(height: 16),
                      _MetricsSection(
                        loadedRevenue: state.loadedRevenue,
                        loadedOrders: state.sales.length,
                        loadedItemsSold: state.loadedItemsSold,
                        loadedAverageTicket: state.loadedAverageTicket,
                      ),
                      if (state.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        _ErrorBanner(message: state.errorMessage!),
                      ],
                    ],
                  ),
                ),
              ),
              if (state.isLoading && state.sales.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.sales.isEmpty)
                const SliverFillRemaining(child: _EmptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final sale = state.sales[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SaleHistoryCard(sale: sale),
                      );
                    }, childCount: state.sales.length),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
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

  Future<void> _selectDateRange(
    BuildContext context,
    SalesHistoryViewModel viewModel,
    SalesHistoryState state,
  ) async {
    final now = DateTime.now();

    final initialDateRange = state.startDate != null && state.endDate != null
        ? DateTimeRange(start: state.startDate!, end: state.endDate!)
        : DateTimeRange(start: DateTime(now.year, now.month, 1), end: now);

    final selectedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: initialDateRange,
      helpText: 'Filtrar vendas por período',
      cancelText: 'Cancelar',
      confirmText: 'Aplicar',
      saveText: 'Aplicar',
    );

    if (selectedRange == null) return;

    await viewModel.setDateRange(
      startDate: selectedRange.start,
      endDate: selectedRange.end,
    );
  }
}

class _Header extends StatelessWidget {
  final int totalCount;
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onSelectDateRange;
  final VoidCallback? onClearDateRange;

  const _Header({
    required this.totalCount,
    required this.startDate,
    required this.endDate,
    required this.onSelectDateRange,
    required this.onClearDateRange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final periodText = _periodText();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.payments_rounded,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Histórico de Vendas',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalCount vendas encontradas • $periodText',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: onSelectDateRange,
                    icon: const Icon(Icons.date_range_rounded),
                    label: const Text('Filtrar período'),
                  ),
                  if (onClearDateRange != null)
                    OutlinedButton.icon(
                      onPressed: onClearDateRange,
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Limpar filtro'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _periodText() {
    if (startDate == null || endDate == null) {
      return 'todos os períodos';
    }

    final formatter = DateFormat('dd/MM/yyyy');

    return '${formatter.format(startDate!)} até ${formatter.format(endDate!)}';
  }
}

class _MetricsSection extends StatelessWidget {
  final double loadedRevenue;
  final int loadedOrders;
  final int loadedItemsSold;
  final double loadedAverageTicket;

  const _MetricsSection({
    required this.loadedRevenue,
    required this.loadedOrders,
    required this.loadedItemsSold,
    required this.loadedAverageTicket,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 850;

        final cards = [
          _MetricCard(
            title: 'Faturamento carregado',
            value: CurrencyFormatter.format(loadedRevenue),
            icon: Icons.attach_money_rounded,
          ),
          _MetricCard(
            title: 'Vendas carregadas',
            value: loadedOrders.toString(),
            icon: Icons.receipt_long_rounded,
          ),
          _MetricCard(
            title: 'Itens vendidos',
            value: loadedItemsSold.toString(),
            icon: Icons.restaurant_menu_rounded,
          ),
          _MetricCard(
            title: 'Ticket médio carregado',
            value: CurrencyFormatter.format(loadedAverageTicket),
            icon: Icons.trending_up_rounded,
          ),
        ];

        if (isWide) {
          return Row(
            children: cards
                .map(
                  (card) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: card,
                    ),
                  ),
                )
                .toList(),
          );
        }

        return Column(
          children: cards
              .map(
                (card) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: card,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.12),
              child: Icon(icon, color: AppColors.primaryDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        child: Text(
          'Nenhuma venda encontrada para o período selecionado.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
