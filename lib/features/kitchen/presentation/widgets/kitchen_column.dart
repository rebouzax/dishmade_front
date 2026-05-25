import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../orders/domain/entities/restaurant_order.dart';
import 'kitchen_order_card.dart';

class KitchenColumn extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final List<RestaurantOrder> orders;
  final String emptyMessage;
  final String? processingOrderId;
  final ValueChanged<RestaurantOrder> onAdvance;

  const KitchenColumn({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.orders,
    required this.emptyMessage,
    required this.processingOrderId,
    required this.onAdvance,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: accentColor.withOpacity(0.12),
                child: Icon(icon, color: accentColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  orders.length.toString(),
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (orders.isEmpty)
            _EmptyColumnMessage(message: emptyMessage)
          else
            ...orders.map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: KitchenOrderCard(
                  order: order,
                  isProcessing: processingOrderId == order.id,
                  onAdvance: () => onAdvance(order),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyColumnMessage extends StatelessWidget {
  final String message;

  const _EmptyColumnMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
