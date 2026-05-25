import 'package:dishmade_front/features/categories/domain/entities/dish_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../categories/presentation/viewmodels/categories_provider.dart';
import '../../domain/entities/dish.dart';
import '../viewmodels/dish_form_viewmodel.dart';

class DishFormPage extends ConsumerStatefulWidget {
  final Dish? dish;

  const DishFormPage({super.key, this.dish});

  @override
  ConsumerState<DishFormPage> createState() => _DishFormPageState();
}

class _DishFormPageState extends ConsumerState<DishFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;

  String? _selectedCategoryId;

  bool get _isEditing => widget.dish != null;

  @override
  void initState() {
    super.initState();

    final dish = widget.dish;

    _nameController = TextEditingController(text: dish?.name ?? '');
    _descriptionController = TextEditingController(
      text: dish?.description ?? '',
    );
    _priceController = TextEditingController(
      text: dish == null
          ? ''
          : dish.price.toStringAsFixed(2).replaceAll('.', ','),
    );

    _selectedCategoryId = dish?.categoryId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(dishFormViewModelProvider);
    final categoriesAsync = ref.watch(activeCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar prato' : 'Novo prato')),
      body: SafeArea(
        child: categoriesAsync.when(
          data: (categories) {
            return _buildForm(
              context: context,
              categories: categories,
              isSaving: formState.isSaving,
              errorMessage: formState.errorMessage,
            );
          },
          loading: () {
            return const Center(child: CircularProgressIndicator());
          },
          error: (_, __) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Não foi possível carregar as categorias.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm({
    required BuildContext context,
    required List<DishCategory> categories,
    required bool isSaving,
    required String? errorMessage,
  }) {
    final categoryExists = categories.any(
      (category) => category.id == _selectedCategoryId,
    );

    final dropdownValue = categoryExists ? _selectedCategoryId : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FormHeader(isEditing: _isEditing),
                    const SizedBox(height: 24),

                    if (errorMessage != null) ...[
                      _ErrorBanner(message: errorMessage),
                      const SizedBox(height: 16),
                    ],

                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nome do prato',
                        hintText: 'Ex: Smash Burger',
                        prefixIcon: Icon(Icons.restaurant_menu_rounded),
                      ),
                      maxLength: 150,
                      validator: (value) {
                        final text = value?.trim() ?? '';

                        if (text.isEmpty) {
                          return 'Informe o nome do prato.';
                        }

                        if (text.length > 150) {
                          return 'O nome deve ter no máximo 150 caracteres.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _descriptionController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        hintText: 'Ex: Pão brioche, carne smash e cheddar',
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                      maxLines: 4,
                      maxLength: 1000,
                      validator: (value) {
                        final text = value?.trim() ?? '';

                        if (text.length > 1000) {
                          return 'A descrição deve ter no máximo 1000 caracteres.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Preço',
                        hintText: 'Ex: 29,90',
                        prefixIcon: Icon(Icons.attach_money_rounded),
                      ),
                      validator: (value) {
                        final price = _parsePrice(value);

                        if (price == null) {
                          return 'Informe um preço válido.';
                        }

                        if (price <= 0) {
                          return 'O preço deve ser maior que zero.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    DropdownButtonFormField<String>(
                      value: dropdownValue,
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: isSaving
                          ? null
                          : (value) {
                              setState(() {
                                _selectedCategoryId = value;
                              });
                            },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecione uma categoria.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSaving
                                ? null
                                : () {
                                    Navigator.of(context).pop(false);
                                  },
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: isSaving ? null : _submit,
                            icon: isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save_rounded),
                            label: Text(
                              isSaving
                                  ? 'Salvando...'
                                  : _isEditing
                                  ? 'Salvar alterações'
                                  : 'Criar prato',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    final categoryId = _selectedCategoryId;
    final price = _parsePrice(_priceController.text);

    if (categoryId == null || price == null) return;

    final viewModel = ref.read(dishFormViewModelProvider.notifier);

    final success = _isEditing
        ? await viewModel.updateDish(
            id: widget.dish!.id,
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            price: price,
            categoryId: categoryId,
          )
        : await viewModel.createDish(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            price: price,
            categoryId: categoryId,
          );

    if (!mounted || !success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditing
              ? 'Prato atualizado com sucesso.'
              : 'Prato criado com sucesso.',
        ),
      ),
    );

    Navigator.of(context).pop(true);
  }

  double? _parsePrice(String? value) {
    final normalized = value?.trim().replaceAll('.', '').replaceAll(',', '.');

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return double.tryParse(normalized);
  }
}

class _FormHeader extends StatelessWidget {
  final bool isEditing;

  const _FormHeader({required this.isEditing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.restaurant_menu_rounded,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Editar item do cardápio' : 'Cadastrar item',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Preencha os dados principais do prato.',
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

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
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
