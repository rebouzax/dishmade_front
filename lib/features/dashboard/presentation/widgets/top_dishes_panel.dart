import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/top_dish.dart';

class TopDishesPanel extends StatelessWidget {
  final List<TopDish> dishes;

  const TopDishesPanel({super.key, required this.dishes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final maxRevenue = dishes.isEmpty
        ? 0.0
        : dishes
              .map((dish) => dish.revenue)
              .reduce((current, next) => current > next ? current : next);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pratos mais vendidos',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Top 5 por quantidade vendida e faturamento',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            if (dishes.isEmpty)
              const _EmptyTopDishes()
            else
              ...dishes.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _TopDishRow(
                    position: entry.key + 1,
                    dish: entry.value,
                    progress: maxRevenue <= 0
                        ? 0
                        : entry.value.revenue / maxRevenue,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TopDishRow extends StatelessWidget {
  final int position;
  final TopDish dish;
  final double progress;

  const _TopDishRow({
    required this.position,
    required this.dish,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primary.withOpacity(0.12),
          child: Text(
            position.toString(),
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      dish.dishName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    CurrencyFormatter.format(dish.revenue),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${dish.quantitySold} unidades vendidas',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 8,
                borderRadius: BorderRadius.circular(999),
                backgroundColor: AppColors.border,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyTopDishes extends StatelessWidget {
  const _EmptyTopDishes();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Text(
        'Nenhum prato vendido no período selecionado.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
