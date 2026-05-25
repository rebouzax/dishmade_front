import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../orders/domain/entities/order_status.dart';
import '../../../orders/domain/entities/restaurant_order.dart';

class KitchenOrderCard extends StatelessWidget {
  final RestaurantOrder order;
  final bool isProcessing;
  final VoidCallback onAdvance;

  const KitchenOrderCard({
    super.key,
    required this.order,
    required this.isProcessing,
    required this.onAdvance,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalItems = order.items.fold<int>(
      0,
      (total, item) => total + item.quantity,
    );

    final nextStatusLabel = order.status.nextStatusLabel;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _statusColor(order.status).withOpacity(0.12),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: _statusColor(order.status),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Mesa ${order.tableNumber}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _StatusChip(status: order.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$totalItems itens • ${CurrencyFormatter.format(order.total)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 6),
            if (order.items.isEmpty)
              const Text('Pedido sem itens.')
            else
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.quantity}x',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.dishName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isProcessing || nextStatusLabel == null
                    ? null
                    : onAdvance,
                icon: isProcessing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : _nextStatusIcon(order.status),
                label: Text(
                  isProcessing
                      ? 'Atualizando...'
                      : nextStatusLabel ?? 'Finalizado',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(OrderStatus status) {
    return switch (status) {
      OrderStatus.created => AppColors.warning,
      OrderStatus.inPreparation => AppColors.primary,
      OrderStatus.ready => AppColors.success,
      OrderStatus.delivered => AppColors.textSecondary,
      OrderStatus.canceled => AppColors.danger,
    };
  }

  Icon _nextStatusIcon(OrderStatus status) {
    return switch (status) {
      OrderStatus.created => const Icon(Icons.play_arrow_rounded),
      OrderStatus.inPreparation => const Icon(Icons.check_circle_outline),
      OrderStatus.ready => const Icon(Icons.delivery_dining_rounded),
      _ => const Icon(Icons.done_all_rounded),
    };
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      OrderStatus.created => AppColors.warning,
      OrderStatus.inPreparation => AppColors.primary,
      OrderStatus.ready => AppColors.success,
      OrderStatus.delivered => AppColors.textSecondary,
      OrderStatus.canceled => AppColors.danger,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}
