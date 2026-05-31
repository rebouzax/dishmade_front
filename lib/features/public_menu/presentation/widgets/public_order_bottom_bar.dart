import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/public_order.dart';

class PublicOrderBottomBar extends StatelessWidget {
  final PublicOrder order;
  final bool isSaving;
  final VoidCallback onViewOrder;

  const PublicOrderBottomBar({
    super.key,
    required this.order,
    required this.isSaving,
    required this.onViewOrder,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.12),
              child: const Icon(
                Icons.shopping_bag_rounded,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${order.totalItems} itens • ${CurrencyFormatter.format(order.total)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            FilledButton(
              onPressed: isSaving ? null : onViewOrder,
              child: const Text('Ver pedido'),
            ),
          ],
        ),
      ),
    );
  }
}
