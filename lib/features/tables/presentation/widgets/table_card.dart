import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/restaurant_table.dart';

class TableCard extends StatelessWidget {
  final RestaurantTable table;
  final VoidCallback onEdit;
  final VoidCallback onToggleOccupation;
  final VoidCallback onDelete;
  final VoidCallback onEnableQrCode;
  final VoidCallback onDisableQrCode;
  final VoidCallback onViewQrCode;
  final VoidCallback onCopyQrCodeLink;

  const TableCard({
    super.key,
    required this.table,
    required this.onEdit,
    required this.onToggleOccupation,
    required this.onDelete,
    required this.onEnableQrCode,
    required this.onDisableQrCode,
    required this.onViewQrCode,
    required this.onCopyQrCodeLink,
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
                    if (value == 'enableQr') onEnableQrCode();
                    if (value == 'disableQr') onDisableQrCode();
                    if (value == 'viewQr') onViewQrCode();
                    if (value == 'copyQr') onCopyQrCodeLink();
                  },
                  itemBuilder: (context) {
                    final items = <PopupMenuEntry<String>>[
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
                    ];

                    if (!table.isMenuQrCodeEnabled) {
                      items.add(
                        const PopupMenuItem(
                          value: 'enableQr',
                          child: Text('Habilitar QR Code'),
                        ),
                      );
                    } else {
                      items.addAll([
                        const PopupMenuItem(
                          value: 'viewQr',
                          child: Text('Visualizar QR Code'),
                        ),
                        const PopupMenuItem(
                          value: 'copyQr',
                          child: Text('Copiar link do cardápio'),
                        ),
                        const PopupMenuItem(
                          value: 'disableQr',
                          child: Text('Desabilitar QR Code'),
                        ),
                      ]);
                    }

                    items.add(
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Remover mesa'),
                      ),
                    );

                    return items;
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
            const SizedBox(height: 8),
            _QrCodeBadge(isEnabled: table.isMenuQrCodeEnabled),
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

class _QrCodeBadge extends StatelessWidget {
  final bool isEnabled;

  const _QrCodeBadge({required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    final color = isEnabled ? AppColors.primary : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isEnabled ? 'QR ativo' : 'QR inativo',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}
