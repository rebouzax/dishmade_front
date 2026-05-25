import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/viewmodels/auth_controller.dart';
import '../viewmodels/admin_clients_viewmodel.dart';
import '../widgets/admin_client_card.dart';

class AdminClientsPage extends ConsumerStatefulWidget {
  const AdminClientsPage({super.key});

  @override
  ConsumerState<AdminClientsPage> createState() => _AdminClientsPageState();
}

class _AdminClientsPageState extends ConsumerState<AdminClientsPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminClientsViewModelProvider);
    final viewModel = ref.read(adminClientsViewModelProvider.notifier);
    final session = ref.watch(authControllerProvider).session;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administração de Clientes'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: state.isLoading ? null : viewModel.refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Sair',
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: state.isSaving ? null : _openCreateClientDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo cliente'),
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
                            adminName: session?.user.name,
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
                  if (state.isLoading && state.clients.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.clients.isEmpty)
                    const SliverFillRemaining(child: _EmptyState())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final client = state.clients[index];

                          return AdminClientCard(client: client);
                        }, childCount: state.clients.length),
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
    if (width >= 1200) return 4;
    if (width >= 850) return 3;
    if (width >= 560) return 2;
    return 1;
  }

  double _getChildAspectRatio(double width) {
    if (width >= 1200) return 1.28;
    if (width >= 850) return 1.18;
    if (width >= 560) return 1.12;
    return 1.45;
  }

  Future<void> _openCreateClientDialog() async {
    final result = await showDialog<_CreateClientFormResult>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return const _CreateAdminClientDialog();
      },
    );

    if (result == null) return;

    final success = await ref
        .read(adminClientsViewModelProvider.notifier)
        .createClient(
          restaurantName: result.restaurantName,
          restaurantDocument: result.restaurantDocument,
          userName: result.userName,
          email: result.email,
          password: result.password,
        );

    if (!mounted || !success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cliente criado com sucesso.')),
    );
  }
}

class _CreateClientFormResult {
  final String restaurantName;
  final String? restaurantDocument;
  final String userName;
  final String email;
  final String password;

  const _CreateClientFormResult({
    required this.restaurantName,
    required this.restaurantDocument,
    required this.userName,
    required this.email,
    required this.password,
  });
}

class _CreateAdminClientDialog extends StatefulWidget {
  const _CreateAdminClientDialog();

  @override
  State<_CreateAdminClientDialog> createState() =>
      _CreateAdminClientDialogState();
}

class _CreateAdminClientDialogState extends State<_CreateAdminClientDialog> {
  final _formKey = GlobalKey<FormState>();

  final _restaurantNameController = TextEditingController();
  final _restaurantDocumentController = TextEditingController();
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _restaurantNameController.dispose();
    _restaurantDocumentController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    final dialogWidth = (screenSize.width - 32).clamp(320.0, 560.0);
    final dialogMaxHeight = (screenSize.height - 48).clamp(420.0, 700.0);

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SizedBox(
        width: dialogWidth,
        height: dialogMaxHeight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
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
                      Icons.storefront_rounded,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Novo cliente',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fechar',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _restaurantNameController,
                        textInputAction: TextInputAction.next,
                        maxLength: 150,
                        decoration: const InputDecoration(
                          labelText: 'Nome do restaurante',
                          hintText: 'Ex: Cafeteria Doce Café',
                          prefixIcon: Icon(Icons.storefront_rounded),
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';

                          if (text.isEmpty) {
                            return 'Informe o nome do restaurante.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _restaurantDocumentController,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9./-]'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Documento do restaurante',
                          hintText: 'Opcional',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _userNameController,
                        textInputAction: TextInputAction.next,
                        maxLength: 120,
                        decoration: const InputDecoration(
                          labelText: 'Nome do usuário',
                          hintText: 'Ex: Dougliane',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';

                          if (text.isEmpty) {
                            return 'Informe o nome do usuário.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'cliente@email.com',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';

                          if (text.isEmpty) {
                            return 'Informe o email.';
                          }

                          if (!text.contains('@')) {
                            return 'Informe um email válido.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'Senha inicial',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          final text = value ?? '';

                          if (text.isEmpty) {
                            return 'Informe a senha inicial.';
                          }

                          if (text.length < 6) {
                            return 'A senha deve ter pelo menos 6 caracteres.';
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
                      label: const Text('Criar cliente'),
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

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    Navigator.of(context).pop(
      _CreateClientFormResult(
        restaurantName: _restaurantNameController.text.trim(),
        restaurantDocument: _restaurantDocumentController.text.trim().isEmpty
            ? null
            : _restaurantDocumentController.text.trim(),
        userName: _userNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int totalCount;
  final String? adminName;

  const _Header({required this.totalCount, required this.adminName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.admin_panel_settings_rounded,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clientes da plataforma',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${adminName == null ? 'Administrador' : adminName} • '
                '$totalCount clientes encontrados',
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
        hintText: 'Buscar por nome, email ou restaurante',
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
          label: const Text('Todos'),
          selected: selectedValue == null,
          onSelected: (_) => onChanged(null),
        ),
        ChoiceChip(
          label: const Text('Ativos'),
          selected: selectedValue == true,
          onSelected: (_) => onChanged(true),
        ),
        ChoiceChip(
          label: const Text('Inativos'),
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
        child: Text('Nenhum cliente encontrado.', textAlign: TextAlign.center),
      ),
    );
  }
}
