import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/public_dish.dart';
import '../../domain/entities/public_dish_option.dart';
import '../../domain/entities/public_dish_option_group.dart';

class AddPublicDishDialogResult {
  final int quantity;
  final String? notes;
  final List<String> optionIds;

  const AddPublicDishDialogResult({
    required this.quantity,
    this.notes,
    this.optionIds = const [],
  });
}

class AddPublicDishDialog extends StatefulWidget {
  final PublicDish dish;

  const AddPublicDishDialog({super.key, required this.dish});

  @override
  State<AddPublicDishDialog> createState() => _AddPublicDishDialogState();
}

class _AddPublicDishDialogState extends State<AddPublicDishDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  final Map<String, Set<String>> _selectedOptionsByGroup = {};

  @override
  void initState() {
    super.initState();
    for (final group in widget.dish.optionGroups) {
      _selectedOptionsByGroup[group.id] = <String>{};
    }
    _quantityController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final dialogWidth = (screenSize.width - 32).clamp(320.0, 620.0).toDouble();
    final dialogMaxHeight = (screenSize.height - 48)
        .clamp(480.0, 760.0)
        .toDouble();

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SizedBox(
        width: dialogWidth,
        height: dialogMaxHeight,
        child: Column(
          children: [
            _Header(dish: widget.dish, totalPreview: _calculateTotalPreview()),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _quantityController,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Quantidade',
                          prefixIcon: Icon(Icons.numbers_rounded),
                        ),
                        validator: (value) {
                          final quantity = int.tryParse(value?.trim() ?? '');
                          if (quantity == null || quantity <= 0) {
                            return 'Informe uma quantidade válida.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      if (widget.dish.optionGroups.isNotEmpty) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Adicionais e modificadores',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...widget.dish.optionGroups.map(
                          (group) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _OptionGroupSelector(
                              group: group,
                              selectedOptionIds:
                                  _selectedOptionsByGroup[group.id] ??
                                  <String>{},
                              onToggle: (option) {
                                _toggleOption(group, option);
                              },
                            ),
                          ),
                        ),
                      ],
                      TextFormField(
                        controller: _notesController,
                        maxLength: 500,
                        maxLines: 4,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        decoration: const InputDecoration(
                          labelText: 'Observação',
                          hintText: 'Ex: Sem cebola, massa fina, pouco molho',
                          prefixIcon: Icon(Icons.notes_rounded),
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.length > 500) {
                            return 'A observação deve ter no máximo 500 caracteres.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Adicionar'),
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

  void _toggleOption(PublicDishOptionGroup group, PublicDishOption option) {
    final selectedIds = _selectedOptionsByGroup[group.id] ?? <String>{};
    final isSelected = selectedIds.contains(option.id);

    setState(() {
      if (isSelected) {
        selectedIds.remove(option.id);
      } else {
        if (group.maxSelection == 1) {
          selectedIds
            ..clear()
            ..add(option.id);
        } else {
          if (selectedIds.length >= group.maxSelection) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'O grupo "${group.name}" permite no máximo '
                  '${group.maxSelection} opção(ões).',
                ),
              ),
            );
            return;
          }
          selectedIds.add(option.id);
        }
      }
      _selectedOptionsByGroup[group.id] = selectedIds;
    });
  }

  double _calculateOptionsTotal() {
    var total = 0.0;
    for (final group in widget.dish.optionGroups) {
      final selectedIds = _selectedOptionsByGroup[group.id] ?? <String>{};
      for (final option in group.options) {
        if (selectedIds.contains(option.id)) {
          total += option.additionalPrice;
        }
      }
    }
    return total;
  }

  double _calculateTotalPreview() {
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 1;
    final unitTotal = widget.dish.price + _calculateOptionsTotal();
    return unitTotal * quantity;
  }

  List<String> _selectedOptionIds() {
    return _selectedOptionsByGroup.values
        .expand((optionIds) => optionIds)
        .toList();
  }

  String? _validateOptionGroups() {
    for (final group in widget.dish.optionGroups) {
      final selectedCount =
          (_selectedOptionsByGroup[group.id] ?? <String>{}).length;
      if (selectedCount < group.minSelection) {
        return 'O grupo "${group.name}" exige no mínimo '
            '${group.minSelection} opção(ões).';
      }
      if (selectedCount > group.maxSelection) {
        return 'O grupo "${group.name}" permite no máximo '
            '${group.maxSelection} opção(ões).';
      }
      if (group.isRequired && selectedCount == 0) {
        return 'O grupo "${group.name}" é obrigatório.';
      }
    }
    return null;
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final optionValidationMessage = _validateOptionGroups();
    if (optionValidationMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(optionValidationMessage)));
      return;
    }

    Navigator.of(context).pop(
      AddPublicDishDialogResult(
        quantity: int.parse(_quantityController.text.trim()),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        optionIds: _selectedOptionIds(),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final PublicDish dish;
  final double totalPreview;

  const _Header({required this.dish, required this.totalPreview});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.restaurant_menu_rounded,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dish.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total: ${CurrencyFormatter.format(totalPreview)}',
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Fechar',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

class _OptionGroupSelector extends StatelessWidget {
  final PublicDishOptionGroup group;
  final Set<String> selectedOptionIds;
  final ValueChanged<PublicDishOption> onToggle;

  const _OptionGroupSelector({
    required this.group,
    required this.selectedOptionIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isSingleSelection = group.maxSelection == 1;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    group.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _GroupRuleBadge(group: group),
              ],
            ),
          ),
          if (group.options.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Nenhuma opção disponível.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ...group.options.map((option) {
              final selected = selectedOptionIds.contains(option.id);
              return InkWell(
                onTap: () => onToggle(option),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  child: isSingleSelection
                      ? RadioListTile<bool>(
                          value: true,
                          groupValue: selected,
                          onChanged: (_) => onToggle(option),
                          title: Text(option.name),
                          subtitle: option.additionalPrice > 0
                              ? Text(
                                  '+ ${CurrencyFormatter.format(option.additionalPrice)}',
                                )
                              : const Text('Sem adicional'),
                        )
                      : CheckboxListTile(
                          value: selected,
                          onChanged: (_) => onToggle(option),
                          title: Text(option.name),
                          subtitle: option.additionalPrice > 0
                              ? Text(
                                  '+ ${CurrencyFormatter.format(option.additionalPrice)}',
                                )
                              : const Text('Sem adicional'),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _GroupRuleBadge extends StatelessWidget {
  final PublicDishOptionGroup group;

  const _GroupRuleBadge({required this.group});

  @override
  Widget build(BuildContext context) {
    final text = group.isRequired
        ? 'Obrigatório • ${group.minSelection}-${group.maxSelection}'
        : 'Opcional • máx. ${group.maxSelection}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: group.isRequired
            ? AppColors.warning.withOpacity(0.12)
            : AppColors.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: group.isRequired ? AppColors.warning : AppColors.primaryDark,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
