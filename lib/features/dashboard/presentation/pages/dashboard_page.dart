import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../viewmodels/dashboard_state.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../widgets/dashboard_metric_card.dart';
import '../widgets/top_dishes_panel.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardViewModelProvider);
    final viewModel = ref.read(dashboardViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
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
                        state: state,
                        onSelectDateRange: () {
                          _selectDateRange(context, viewModel, state);
                        },
                        onCurrentMonth: viewModel.setCurrentMonth,
                        onClearDateRange: viewModel.clearDateRange,
                      ),
                      if (state.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        _ErrorBanner(message: state.errorMessage!),
                      ],
                      const SizedBox(height: 18),
                      if (state.isLoading)
                        const SizedBox(
                          height: 320,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else ...[
                        _MetricsGrid(state: state),
                        const SizedBox(height: 16),
                        TopDishesPanel(dishes: state.summary.topDishes),
                      ],
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

  Future<void> _selectDateRange(
    BuildContext context,
    DashboardViewModel viewModel,
    DashboardState state,
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
      helpText: 'Filtrar dashboard por período',
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
  final DashboardState state;
  final VoidCallback onSelectDateRange;
  final VoidCallback onCurrentMonth;
  final VoidCallback onClearDateRange;

  const _Header({
    required this.state,
    required this.onSelectDateRange,
    required this.onCurrentMonth,
    required this.onClearDateRange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastUpdateText = state.lastUpdatedAt == null
        ? 'Ainda não atualizado'
        : 'Atualizado às ${TimeOfDay.fromDateTime(state.lastUpdatedAt!).format(context)}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.dashboard_rounded,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard do Restaurante',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_periodText()} • $lastUpdateText',
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
                  OutlinedButton.icon(
                    onPressed: onCurrentMonth,
                    icon: const Icon(Icons.calendar_month_rounded),
                    label: const Text('Mês atual'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onClearDateRange,
                    icon: const Icon(Icons.all_inclusive_rounded),
                    label: const Text('Todos'),
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
    if (state.startDate == null || state.endDate == null) {
      return 'Todos os períodos';
    }

    final formatter = DateFormat('dd/MM/yyyy');

    return '${formatter.format(state.startDate!)} até ${formatter.format(state.endDate!)}';
  }
}

class _MetricsGrid extends StatelessWidget {
  final DashboardState state;

  const _MetricsGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    final summary = state.summary;

    final cards = [
      DashboardMetricCard(
        title: 'Faturamento',
        value: CurrencyFormatter.format(summary.totalRevenue),
        subtitle: 'Pedidos entregues no período',
        icon: Icons.attach_money_rounded,
        accentColor: AppColors.success,
      ),
      DashboardMetricCard(
        title: 'Pedidos entregues',
        value: summary.totalOrders.toString(),
        subtitle: 'Total de vendas concluídas',
        icon: Icons.receipt_long_rounded,
        accentColor: AppColors.primary,
      ),
      DashboardMetricCard(
        title: 'Itens vendidos',
        value: summary.totalItemsSold.toString(),
        subtitle: 'Soma das quantidades vendidas',
        icon: Icons.restaurant_menu_rounded,
        accentColor: AppColors.warning,
      ),
      DashboardMetricCard(
        title: 'Ticket médio',
        value: CurrencyFormatter.format(summary.averageTicket),
        subtitle: 'Faturamento dividido pelos pedidos',
        icon: Icons.trending_up_rounded,
        accentColor: AppColors.primaryDark,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= 1000) {
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

        if (width >= 650) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 10),
                  Expanded(child: cards[1]),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: cards[2]),
                  const SizedBox(width: 10),
                  Expanded(child: cards[3]),
                ],
              ),
            ],
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
