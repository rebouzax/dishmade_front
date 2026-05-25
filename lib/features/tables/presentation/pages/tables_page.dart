import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/restaurant_table.dart';
import '../viewmodels/tables_viewmodel.dart';
import '../widgets/table_card.dart';

class TablesPage extends ConsumerStatefulWidget {
  const TablesPage({super.key});

  @override
  ConsumerState<TablesPage> createState() => _TablesPageState();
}

class _TablesPageState extends ConsumerState<TablesPage> {
  final _numberFilterController = TextEditingController();

  @override
  void dispose() {
    _numberFilterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tablesViewModelProvider);
    final viewModel = ref.read(tablesViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesas'),
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
        onPressed: state.isSaving ? null : () => _openTableDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova mesa'),
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
                          _Filters(
                            controller: _numberFilterController,
                            selectedOccupation: state.isOccupied,
                            onSearchNumber: (value) {
                              final number = int.tryParse(value.trim());
                              viewModel.setNumberFilter(number);
                            },
                            onClearNumber: () {
                              _numberFilterController.clear();
                              viewModel.setNumberFilter(null);
                            },
                            onOccupationChanged: viewModel.setOccupiedFilter,
                          ),
                          if (state.errorMessage != null) ...[
                            const SizedBox(height: 16),
                            _ErrorBanner(message: state.errorMessage!),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (state.isLoading && state.tables.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.tables.isEmpty)
                    const SliverFillRemaining(child: _EmptyState())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final table = state.tables[index];

                          return TableCard(
                            table: table,
                            onEdit: () =>
                                _openTableDialog(context, table: table),
                            onToggleOccupation: () {
                              if (table.isOccupied) {
                                viewModel.releaseTable(table.id);
                              } else {
                                viewModel.occupyTable(table.id);
                              }
                            },
                            onDelete: () => _confirmDelete(context, table),
                          );
                        }, childCount: state.tables.length),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.2,
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
    if (width >= 1100) return 5;
    if (width >= 850) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  Future<void> _openTableDialog(
    BuildContext context, {
    RestaurantTable? table,
  }) async {
    final controller = TextEditingController(
      text: table?.number.toString() ?? '',
    );

    final isEditing = table != null;

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Editar mesa' : 'Nova mesa'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Número da mesa',
              hintText: 'Ex: 2',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final number = int.tryParse(controller.text.trim());

                if (number == null || number <= 0) {
                  return;
                }

                Navigator.of(context).pop(number);
              },
              child: Text(isEditing ? 'Salvar' : 'Criar'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null) return;

    final viewModel = ref.read(tablesViewModelProvider.notifier);

    final success = isEditing
        ? await viewModel.updateTable(id: table.id, number: result)
        : await viewModel.createTable(result);

    if (!mounted || !success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditing
              ? 'Mesa atualizada com sucesso.'
              : 'Mesa criada com sucesso.',
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    RestaurantTable table,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remover mesa'),
          content: Text(
            'Deseja remover a mesa ${table.number}? '
            'Mesas ocupadas não podem ser removidas.',
          ),
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
        .read(tablesViewModelProvider.notifier)
        .deleteTable(table.id);

    if (!mounted || !success) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Mesa removida com sucesso.')));
  }
}

class _Header extends StatelessWidget {
  final int totalCount;

  const _Header({required this.totalCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gestão de mesas',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$totalCount mesas encontradas',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _Filters extends StatelessWidget {
  final TextEditingController controller;
  final bool? selectedOccupation;
  final ValueChanged<String> onSearchNumber;
  final VoidCallback onClearNumber;
  final ValueChanged<bool?> onOccupationChanged;

  const _Filters({
    required this.controller,
    required this.selectedOccupation,
    required this.onSearchNumber,
    required this.onClearNumber,
    required this.onOccupationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.search,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onSubmitted: onSearchNumber,
          decoration: InputDecoration(
            hintText: 'Buscar por número da mesa',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: IconButton(
              onPressed: onClearNumber,
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Todas'),
                selected: selectedOccupation == null,
                onSelected: (_) => onOccupationChanged(null),
              ),
              ChoiceChip(
                label: const Text('Livres'),
                selected: selectedOccupation == false,
                onSelected: (_) => onOccupationChanged(false),
              ),
              ChoiceChip(
                label: const Text('Ocupadas'),
                selected: selectedOccupation == true,
                onSelected: (_) => onOccupationChanged(true),
              ),
            ],
          ),
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
        child: Text('Nenhuma mesa encontrada.', textAlign: TextAlign.center),
      ),
    );
  }
}
