import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/config/env.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/public_dish.dart';

class PublicDishCard extends StatelessWidget {
  final PublicDish dish;
  final VoidCallback? onAdd;

  const PublicDishCard({super.key, required this.dish, this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = _absoluteUrl(dish.imageUrl);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: imageUrl == null
                ? const _PublicDishImagePlaceholder()
                : Image.network(
                    imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return const _PublicDishImagePlaceholder();
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dish.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  dish.description?.isNotEmpty == true
                      ? dish.description!
                      : dish.categoryName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        CurrencyFormatter.format(dish.price),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    FilledButton(
                      onPressed: onAdd,
                      child: const Text('Adicionar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _absoluteUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final baseUrl = Env.apiBaseUrl.endsWith('/')
        ? Env.apiBaseUrl.substring(0, Env.apiBaseUrl.length - 1)
        : Env.apiBaseUrl;

    final path = value.startsWith('/') ? value : '/$value';

    return '$baseUrl$path';
  }
}

class _PublicDishImagePlaceholder extends StatelessWidget {
  const _PublicDishImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
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
          size: 46,
        ),
      ),
    );
  }
}
