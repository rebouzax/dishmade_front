import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../orders/domain/entities/order_item.dart';
import '../../../orders/domain/entities/order_item_status.dart';
import '../../../orders/domain/entities/order_status.dart';
import '../../../orders/domain/entities/restaurant_order.dart';

class KitchenOrderCard extends StatelessWidget {
  final RestaurantOrder order;
  final bool isProcessing;
  final VoidCallback onAdvance;
  final Future<void> Function(String itemId, OrderItemStatus status)
  onUpdateItemStatus;

  const KitchenOrderCard({
    super.key,
    required this.order,
    required this.isProcessing,
    required this.onAdvance,
    required this.onUpdateItemStatus,
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
                  backgroundColor: _orderStatusColor(
                    order.status,
                  ).withOpacity(0.12),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: _orderStatusColor(order.status),
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
                _OrderStatusChip(status: order.status),
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
                (item) => _KitchenOrderItemTile(
                  item: item,
                  isProcessing: isProcessing,
                  onUpdateStatus: (status) {
                    return onUpdateItemStatus(item.id, status);
                  },
                ),
              ),
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 10),
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

  Color _orderStatusColor(OrderStatus status) {
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

class _KitchenOrderItemTile extends StatelessWidget {
  final OrderItem item;
  final bool isProcessing;
  final Future<void> Function(OrderItemStatus status) onUpdateStatus;

  const _KitchenOrderItemTile({
    required this.item,
    required this.isProcessing,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isCanceled = item.status == OrderItemStatus.canceled;
    final isDelivered = item.status == OrderItemStatus.delivered;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.quantity}x',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  decoration: isCanceled
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.dishName,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        decoration: isCanceled
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _ItemStatusChip(status: item.status),
                    if (item.options.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      ...item.options.map(
                        (option) => Text(
                          '+ ${option.name} (${CurrencyFormatter.format(option.additionalPrice)})',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                    if (item.notes != null &&
                        item.notes!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Obs: ${item.notes}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                CurrencyFormatter.format(item.total),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: isCanceled
                      ? AppColors.textSecondary
                      : AppColors.primaryDark,
                  decoration: isCanceled
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ],
          ),
          if (!isCanceled && !isDelivered) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (item.status.canStartPreparation)
                  OutlinedButton.icon(
                    onPressed: isProcessing
                        ? null
                        : () => onUpdateStatus(OrderItemStatus.inPreparation),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Iniciar'),
                  ),
                if (item.status.canMarkAsReady)
                  FilledButton.icon(
                    onPressed: isProcessing
                        ? null
                        : () => onUpdateStatus(OrderItemStatus.ready),
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Pronto'),
                  ),
                if (item.status.canMarkAsDelivered)
                  OutlinedButton.icon(
                    onPressed: isProcessing
                        ? null
                        : () => onUpdateStatus(OrderItemStatus.delivered),
                    icon: const Icon(Icons.delivery_dining_rounded),
                    label: const Text('Entregar'),
                  ),
                if (item.status.canCancel)
                  TextButton.icon(
                    onPressed: isProcessing
                        ? null
                        : () => onUpdateStatus(OrderItemStatus.canceled),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Cancelar'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.danger,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderStatusChip extends StatelessWidget {
  final OrderStatus status;

  const _OrderStatusChip({required this.status});

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

class _ItemStatusChip extends StatelessWidget {
  final OrderItemStatus status;

  const _ItemStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      OrderItemStatus.created => AppColors.warning,
      OrderItemStatus.inPreparation => AppColors.primary,
      OrderItemStatus.ready => AppColors.success,
      OrderItemStatus.delivered => AppColors.textSecondary,
      OrderItemStatus.canceled => AppColors.danger,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
