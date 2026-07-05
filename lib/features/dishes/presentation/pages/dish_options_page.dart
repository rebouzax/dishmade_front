import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/dish.dart';
import '../../domain/entities/dish_option_group.dart';
import '../viewmodels/dish_options_viewmodel.dart';

class DishOptionsPage extends ConsumerStatefulWidget {
  final Dish dish;

  const DishOptionsPage({super.key, required this.dish});

  @override
  ConsumerState<DishOptionsPage> createState() => _DishOptionsPageState();
}

class _DishOptionsPageState extends ConsumerState<DishOptionsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(dishOptionsViewModelProvider.notifier)
          .loadGroups(widget.dish.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dishOptionsViewModelProvider);
    final viewModel = ref.read(dishOptionsViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionais do prato'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: state.isLoading
                ? null
                : () => viewModel.loadGroups(widget.dish.id),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: state.isSaving ? null : _openCreateGroupDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo grupo'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => viewModel.loadGroups(widget.dish.id),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: _Header(dish: widget.dish),
                ),
              ),
              if (state.errorMessage != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: _ErrorBanner(message: state.errorMessage!),
                  ),
                ),
              if (state.isLoading && state.groups.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.groups.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text('Nenhum grupo de adicionais cadastrado.'),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final group = state.groups[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _OptionGroupCard(
                          group: group,
                          onCreateOption: () => _openCreateOptionDialog(group),
                        ),
                      );
                    }, childCount: state.groups.length),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openCreateGroupDialog() async {
    final result = await showDialog<_CreateGroupResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _CreateGroupDialog(),
    );

    if (result == null) return;

    final success = await ref
        .read(dishOptionsViewModelProvider.notifier)
        .createGroup(
          dishId: widget.dish.id,
          name: result.name,
          isRequired: result.isRequired,
          minSelection: result.minSelection,
          maxSelection: result.maxSelection,
        );

    if (!mounted || !success) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Grupo criado com sucesso.')));
  }

  Future<void> _openCreateOptionDialog(DishOptionGroup group) async {
    final result = await showDialog<_CreateOptionResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CreateOptionDialog(groupName: group.name),
    );

    if (result == null) return;

    final success = await ref
        .read(dishOptionsViewModelProvider.notifier)
        .createOption(
          dishId: widget.dish.id,
          optionGroupId: group.id,
          name: result.name,
          additionalPrice: result.additionalPrice,
        );

    if (!mounted || !success) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Opção criada com sucesso.')));
  }
}

class _Header extends StatelessWidget {
  final Dish dish;

  const _Header({required this.dish});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.12),
              child: const Icon(
                Icons.tune_rounded,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dish.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Configure bordas, adicionais e modificadores.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
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

class _OptionGroupCard extends StatelessWidget {
  final DishOptionGroup group;
  final VoidCallback onCreateOption;

  const _OptionGroupCard({required this.group, required this.onCreateOption});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          group.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          '${group.isRequired ? 'Obrigatório' : 'Opcional'} • '
          'mín. ${group.minSelection} • máx. ${group.maxSelection}',
        ),
        children: [
          const Divider(),
          if (group.options.isEmpty)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Nenhuma opção cadastrada neste grupo.'),
            )
          else
            ...group.options.map(
              (option) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(option.additionalPrice),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: onCreateOption,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nova opção'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
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

class _CreateGroupResult {
  final String name;
  final bool isRequired;
  final int minSelection;
  final int maxSelection;

  const _CreateGroupResult({
    required this.name,
    required this.isRequired,
    required this.minSelection,
    required this.maxSelection,
  });
}

class _CreateGroupDialog extends StatefulWidget {
  const _CreateGroupDialog();

  @override
  State<_CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<_CreateGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _minController = TextEditingController(text: '0');
  final _maxController = TextEditingController(text: '1');
  bool _isRequired = false;

  @override
  void dispose() {
    _nameController.dispose();
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo grupo de opções'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  maxLength: 120,
                  decoration: const InputDecoration(
                    labelText: 'Nome do grupo',
                    hintText: 'Ex: Bordas',
                    prefixIcon: Icon(Icons.tune_rounded),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) {
                      return 'Informe o nome do grupo.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isRequired,
                  title: const Text('Grupo obrigatório'),
                  subtitle: const Text(
                    'O cliente precisa escolher ao menos uma opção.',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isRequired = value;
                      if (value && _minController.text == '0') {
                        _minController.text = '1';
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _minController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Mínimo'),
                        validator: _validateInt,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _maxController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Máximo'),
                        validator: _validateInt,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Criar grupo')),
      ],
    );
  }

  String? _validateInt(String? value) {
    final number = int.tryParse(value?.trim() ?? '');
    if (number == null) {
      return 'Obrigatório';
    }
    if (number < 0) {
      return 'Inválido';
    }
    return null;
  }

  void _submit() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    final min = int.parse(_minController.text.trim());
    final max = int.parse(_maxController.text.trim());

    if (max <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O máximo deve ser maior que zero.')),
      );
      return;
    }

    if (min > max) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O mínimo não pode ser maior que o máximo.'),
        ),
      );
      return;
    }

    if (_isRequired && min <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Grupo obrigatório precisa ter mínimo maior que zero.'),
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      _CreateGroupResult(
        name: _nameController.text.trim(),
        isRequired: _isRequired,
        minSelection: min,
        maxSelection: max,
      ),
    );
  }
}

class _CreateOptionResult {
  final String name;
  final double additionalPrice;

  const _CreateOptionResult({
    required this.name,
    required this.additionalPrice,
  });
}

class _CreateOptionDialog extends StatefulWidget {
  final String groupName;

  const _CreateOptionDialog({required this.groupName});

  @override
  State<_CreateOptionDialog> createState() => _CreateOptionDialogState();
}

class _CreateOptionDialogState extends State<_CreateOptionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController(text: '0');

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Nova opção - ${widget.groupName}'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                maxLength: 120,
                decoration: const InputDecoration(
                  labelText: 'Nome da opção',
                  hintText: 'Ex: Bacon',
                  prefixIcon: Icon(Icons.add_circle_outline_rounded),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return 'Informe o nome da opção.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Preço adicional',
                  hintText: 'Ex: 5.00',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
                validator: (value) {
                  final normalized = (value ?? '').replaceAll(',', '.');
                  final price = double.tryParse(normalized);
                  if (price == null) {
                    return 'Informe um preço válido.';
                  }
                  if (price < 0) {
                    return 'O preço não pode ser negativo.';
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Criar opção')),
      ],
    );
  }

  void _submit() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    Navigator.of(context).pop(
      _CreateOptionResult(
        name: _nameController.text.trim(),
        additionalPrice: double.parse(
          _priceController.text.trim().replaceAll(',', '.'),
        ),
      ),
    );
  }
}
