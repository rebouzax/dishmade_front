import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/restaurant_table.dart';

class TableCard extends StatelessWidget {
  final RestaurantTable table;
  final VoidCallback onEdit;
  final VoidCallback onToggleOccupation;
  final VoidCallback onDelete;

  const TableCard({
    super.key,
    required this.table,
    required this.onEdit,
    required this.onToggleOccupation,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isOccupied = table.isOccupied;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isOccupied
                      ? AppColors.danger.withOpacity(0.12)
                      : AppColors.success.withOpacity(0.12),
                  child: Icon(
                    Icons.table_restaurant_rounded,
                    color: isOccupied ? AppColors.danger : AppColors.success,
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'toggle') onToggleOccupation();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Editar número'),
                      ),
                      PopupMenuItem(
                        value: 'toggle',
                        child: Text(
                          isOccupied ? 'Liberar mesa' : 'Ocupar mesa',
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Remover mesa'),
                      ),
                    ];
                  },
                ),
              ],
            ),
            const Spacer(),
            Text(
              'Mesa ${table.number}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _StatusBadge(isOccupied: isOccupied),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isOccupied;

  const _StatusBadge({required this.isOccupied});

  @override
  Widget build(BuildContext context) {
    final color = isOccupied ? AppColors.danger : AppColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isOccupied ? 'Ocupada' : 'Livre',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}
