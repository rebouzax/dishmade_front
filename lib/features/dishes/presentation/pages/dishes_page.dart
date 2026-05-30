import 'package:dishmade_front/features/categories/domain/entities/dish_category.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../categories/presentation/viewmodels/categories_provider.dart';
import '../../domain/entities/dish.dart';
import '../viewmodels/dish_image_provider.dart';
import '../viewmodels/dishes_viewmodel.dart';
import '../widgets/dish_card.dart';

class DishesPage extends ConsumerStatefulWidget {
  const DishesPage({super.key});

  @override
  ConsumerState<DishesPage> createState() => _DishesPageState();
}

class _DishesPageState extends ConsumerState<DishesPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage(Dish dish) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.single;
    final bytes = file.bytes;

    if (bytes == null || bytes.isEmpty) {
      _showMessage('Não foi possível ler o arquivo selecionado.');
      return;
    }

    if (file.size > 5 * 1024 * 1024) {
      _showMessage('A imagem deve ter no máximo 5MB.');
      return;
    }

    final contentType = _contentTypeFromFileName(file.name);

    if (contentType == null) {
      _showMessage('Formato inválido. Use JPEG, PNG ou WEBP.');
      return;
    }

    final success = await ref
        .read(dishesViewModelProvider.notifier)
        .uploadDishImage(
          dishId: dish.id,
          bytes: bytes,
          fileName: file.name,
          contentType: contentType,
        );

    if (!mounted || !success) return;

    ref.invalidate(dishImageBytesProvider(dish.id));

    _showMessage('Imagem atualizada com sucesso.');
  }

  Future<void> _confirmDeleteImage(Dish dish) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remover imagem'),
          content: Text('Deseja remover a imagem do prato "${dish.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final success = await ref
        .read(dishesViewModelProvider.notifier)
        .deleteDishImage(dish.id);

    if (!mounted || !success) return;

    ref.invalidate(dishImageBytesProvider(dish.id));

    _showMessage('Imagem removida com sucesso.');
  }

  String? _contentTypeFromFileName(String fileName) {
    final lowerName = fileName.toLowerCase();

    if (lowerName.endsWith('.jpg') || lowerName.endsWith('.jpeg')) {
      return 'image/jpeg';
    }

    if (lowerName.endsWith('.png')) {
      return 'image/png';
    }

    if (lowerName.endsWith('.webp')) {
      return 'image/webp';
    }

    return null;
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dishesViewModelProvider);
    final viewModel = ref.read(dishesViewModelProvider.notifier);
    final categoriesAsync = ref.watch(activeCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cardápio'),
        actions: [
          IconButton(
            tooltip: 'Home',
            onPressed: () => context.go(AppRoutes.home),
            icon: const Icon(Icons.home_rounded),
          ),
          IconButton(
            tooltip: 'Atualizar',
            onPressed: state.isLoading ? null : viewModel.refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: viewModel.refresh,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Header(
                            totalCount: state.totalCount,
                            onCreatePressed: () async {
                              final result = await context.push<bool>(
                                AppRoutes.dishForm,
                              );

                              if (result == true) {
                                await viewModel.refresh();
                              }
                            },
                          ),
                          const SizedBox(height: 18),
                          _SearchField(
                            controller: _searchController,
                            onSubmitted: viewModel.setSearch,
                            onClear: () {
                              _searchController.clear();
                              viewModel.setSearch('');
                            },
                          ),
                          const SizedBox(height: 16),
                          _AvailabilityFilters(
                            selectedValue: state.isAvailable,
                            onChanged: viewModel.setAvailability,
                          ),
                          const SizedBox(height: 16),
                          categoriesAsync.when(
                            data: (categories) {
                              return _CategoryFilters(
                                categories: categories,
                                selectedCategoryId: state.categoryId,
                                onChanged: viewModel.setCategory,
                              );
                            },
                            loading: () {
                              return const SizedBox(
                                height: 38,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                            error: (_, __) {
                              return const Text(
                                'Não foi possível carregar categorias.',
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (state.isLoading && state.dishes.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.errorMessage != null && state.dishes.isEmpty)
                    SliverFillRemaining(
                      child: _ErrorState(
                        message: state.errorMessage!,
                        onRetry: viewModel.refresh,
                      ),
                    )
                  else if (state.dishes.isEmpty)
                    const SliverFillRemaining(child: _EmptyState())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return DishCard(
                            dish: state.dishes[index],
                            onTap: () async {
                              final result = await context.push<bool>(
                                AppRoutes.dishForm,
                                extra: state.dishes[index],
                              );

                              if (result == true) {
                                await viewModel.refresh();
                              }
                            },
                            onUploadImage: () {
                              _pickAndUploadImage(state.dishes[index]);
                            },
                            onDeleteImage: () {
                              _confirmDeleteImage(state.dishes[index]);
                            },
                          );
                        }, childCount: state.dishes.length),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.78,
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: _LoadMoreButton(
                        isLoadingMore: state.isLoadingMore,
                        hasNextPage: state.hasNextPage,
                        onPressed: viewModel.loadMore,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  int _getCrossAxisCount(double width) {
    if (width >= 1100) return 5;
    if (width >= 850) return 4;
    if (width >= 600) return 3;
    return 2;
  }
}

class _Header extends StatelessWidget {
  final int totalCount;
  final VoidCallback onCreatePressed;

  const _Header({required this.totalCount, required this.onCreatePressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Produtos',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalCount itens encontrados',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: onCreatePressed,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Novo prato'),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: 'Buscar por nome ou descrição',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          onPressed: onClear,
          icon: const Icon(Icons.close_rounded),
        ),
      ),
    );
  }
}

class _AvailabilityFilters extends StatelessWidget {
  final bool? selectedValue;
  final ValueChanged<bool?> onChanged;

  const _AvailabilityFilters({
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: const Text('Disponíveis'),
          selected: selectedValue == true,
          onSelected: (_) => onChanged(true),
        ),
        ChoiceChip(
          label: const Text('Todos'),
          selected: selectedValue == null,
          onSelected: (_) => onChanged(null),
        ),
        ChoiceChip(
          label: const Text('Indisponíveis'),
          selected: selectedValue == false,
          onSelected: (_) => onChanged(false),
        ),
      ],
    );
  }
}

class _CategoryFilters extends StatelessWidget {
  final List<DishCategory> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onChanged;

  const _CategoryFilters({
    required this.categories,
    required this.selectedCategoryId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return ChoiceChip(
              label: const Text('Todas'),
              selected: selectedCategoryId == null,
              onSelected: (_) => onChanged(null),
            );
          }

          final category = categories[index - 1];

          return ChoiceChip(
            label: Text(category.name),
            selected: selectedCategoryId == category.id,
            onSelected: (_) => onChanged(category.id),
          );
        },
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  final bool isLoadingMore;
  final bool hasNextPage;
  final VoidCallback onPressed;

  const _LoadMoreButton({
    required this.isLoadingMore,
    required this.hasNextPage,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasNextPage) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: isLoadingMore ? null : onPressed,
        child: isLoadingMore
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Carregar mais'),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 42,
              color: AppColors.danger,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('Nenhum prato encontrado.', textAlign: TextAlign.center),
      ),
    );
  }
}
