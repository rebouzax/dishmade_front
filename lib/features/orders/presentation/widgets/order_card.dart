import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/restaurant_order.dart';
import 'order_status_badge.dart';

class OrderCard extends StatelessWidget {
  final RestaurantOrder order;
  final VoidCallback onAddItem;
  final VoidCallback? onNextStatus;
  final VoidCallback? onCancel;

  const OrderCard({
    super.key,
    required this.order,
    required this.onAddItem,
    required this.onNextStatus,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nextStatusLabel = order.status.nextStatusLabel;

    return Card(
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Mesa ${order.tableNumber}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            OrderStatusBadge(status: order.status),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '${order.items.length} itens • ${CurrencyFormatter.format(order.total)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        children: [
          const Divider(),
          if (order.items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Nenhum item adicionado ainda.'),
              ),
            )
          else
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.quantity}x ${item.dishName}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(item.total),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: order.status.canAddItems ? onAddItem : null,
                  icon: const Icon(Icons.add_shopping_cart_rounded),
                  label: const Text('Adicionar item'),
                ),
              ),
              const SizedBox(width: 8),
              if (nextStatusLabel != null)
                Expanded(
                  child: FilledButton(
                    onPressed: onNextStatus,
                    child: Text(nextStatusLabel),
                  ),
                ),
            ],
          ),
          if (order.status.canCancel) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancelar pedido'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
