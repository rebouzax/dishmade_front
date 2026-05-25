import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../viewmodels/categories_viewmodel.dart';
import '../widgets/category_card.dart';

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoriesViewModelProvider);
    final viewModel = ref.read(categoriesViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: state.isSaving ? null : _openCreateCategoryDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova categoria'),
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
                          _Header(totalCount: state.totalCount),
                          const SizedBox(height: 18),
                          _SearchField(
                            controller: _searchController,
                            onSubmitted: viewModel.setSearch,
                            onClear: () {
                              _searchController.clear();
                              viewModel.setSearch('');
                            },
                          ),
                          const SizedBox(height: 14),
                          _ActiveFilters(
                            selectedValue: state.isActive,
                            onChanged: viewModel.setActiveFilter,
                          ),
                          if (state.errorMessage != null) ...[
                            const SizedBox(height: 16),
                            _ErrorBanner(message: state.errorMessage!),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (state.isLoading && state.categories.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.categories.isEmpty)
                    const SliverFillRemaining(child: _EmptyState())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final category = state.categories[index];

                          return CategoryCard(category: category);
                        }, childCount: state.categories.length),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: _getChildAspectRatio(
                            constraints.maxWidth,
                          ),
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
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
    if (width >= 1100) return 4;
    if (width >= 800) return 3;
    if (width >= 560) return 2;
    return 1;
  }

  double _getChildAspectRatio(double width) {
    if (width >= 1100) return 1.35;
    if (width >= 800) return 1.25;
    if (width >= 560) return 1.22;
    return 1.45;
  }

  Future<void> _openCreateCategoryDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<_CategoryFormResult>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Nova categoria'),
          content: SizedBox(
            width: 520,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    maxLength: 100,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      hintText: 'Ex: Hambúrgueres',
                      prefixIcon: Icon(Icons.category_rounded),
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';

                      if (text.isEmpty) {
                        return 'Informe o nome da categoria.';
                      }

                      if (text.length > 100) {
                        return 'O nome deve ter no máximo 100 caracteres.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionController,
                    maxLength: 500,
                    maxLines: 3,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      hintText: 'Ex: Categoria de hambúrgueres artesanais',
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';

                      if (text.length > 500) {
                        return 'A descrição deve ter no máximo 500 caracteres.';
                      }

                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final isValid = formKey.currentState?.validate() ?? false;

                if (!isValid) return;

                Navigator.of(dialogContext).pop(
                  _CategoryFormResult(
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim(),
                  ),
                );
              },
              child: const Text('Criar'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    descriptionController.dispose();

    if (result == null) return;

    final success = await ref
        .read(categoriesViewModelProvider.notifier)
        .createCategory(name: result.name, description: result.description);

    if (!mounted || !success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Categoria criada com sucesso.')),
    );
  }
}

class _CategoryFormResult {
  final String name;
  final String? description;

  const _CategoryFormResult({required this.name, this.description});
}

class _Header extends StatelessWidget {
  final int totalCount;

  const _Header({required this.totalCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.category_rounded, color: AppColors.warning),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Categorias do cardápio',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalCount categorias encontradas',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
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

class _ActiveFilters extends StatelessWidget {
  final bool? selectedValue;
  final ValueChanged<bool?> onChanged;

  const _ActiveFilters({required this.selectedValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: const Text('Ativas'),
          selected: selectedValue == true,
          onSelected: (_) => onChanged(true),
        ),
        ChoiceChip(
          label: const Text('Todas'),
          selected: selectedValue == null,
          onSelected: (_) => onChanged(null),
        ),
        ChoiceChip(
          label: const Text('Inativas'),
          selected: selectedValue == false,
          onSelected: (_) => onChanged(false),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.danger.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Nenhuma categoria encontrada.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
