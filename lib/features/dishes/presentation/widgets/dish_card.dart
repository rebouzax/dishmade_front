import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/dish.dart';
import '../viewmodels/dish_image_provider.dart';

class DishCard extends ConsumerWidget {
  final Dish dish;
  final VoidCallback? onTap;
  final VoidCallback? onUploadImage;
  final VoidCallback? onDeleteImage;

  const DishCard({
    super.key,
    required this.dish,
    this.onTap,
    this.onUploadImage,
    this.onDeleteImage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final imageAsync = ref.watch(dishImageBytesProvider(dish.id));

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  imageAsync.when(
                    data: (bytes) {
                      if (bytes == null || bytes.isEmpty) {
                        return const _DishImagePlaceholder();
                      }

                      return Image.memory(bytes, fit: BoxFit.cover);
                    },
                    loading: () {
                      return const _DishImageLoading();
                    },
                    error: (_, __) {
                      return const _DishImagePlaceholder();
                    },
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _AvailabilityBadge(isAvailable: dish.isAvailable),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: PopupMenuButton<String>(
                      tooltip: 'Imagem do prato',
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Icon(
                          Icons.more_vert_rounded,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      onSelected: (value) {
                        if (value == 'upload') {
                          onUploadImage?.call();
                        }

                        if (value == 'delete') {
                          onDeleteImage?.call();
                        }
                      },
                      itemBuilder: (context) {
                        return const [
                          PopupMenuItem(
                            value: 'upload',
                            child: Text('Enviar / substituir imagem'),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Remover imagem'),
                          ),
                        ];
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dish.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dish.categoryName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.format(dish.price),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDark,
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

class _DishImagePlaceholder extends StatelessWidget {
  const _DishImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF22C7A9), Color(0xFF159A85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.restaurant_menu_rounded,
          color: Colors.white,
          size: 44,
        ),
      ),
    );
  }
}

class _DishImageLoading extends StatelessWidget {
  const _DishImageLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  final bool isAvailable;

  const _AvailabilityBadge({required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.white : AppColors.danger,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isAvailable ? 'Ativo' : 'Inativo',
        style: TextStyle(
          color: isAvailable ? AppColors.primaryDark : Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
