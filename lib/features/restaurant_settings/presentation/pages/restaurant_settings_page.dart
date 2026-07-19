import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../viewmodels/restaurant_settings_viewmodel.dart';

class RestaurantSettingsPage extends ConsumerStatefulWidget {
  const RestaurantSettingsPage({super.key});

  @override
  ConsumerState<RestaurantSettingsPage> createState() =>
      _RestaurantSettingsPageState();
}

class _RestaurantSettingsPageState
    extends ConsumerState<RestaurantSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _serviceFeeController = TextEditingController();

  bool _acceptsQrCodeOrders = true;
  bool _acceptsWaiterCall = true;
  bool _initializedForm = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(restaurantSettingsViewModelProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _serviceFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(restaurantSettingsViewModelProvider);
    final settings = state.settings;

    if (!_initializedForm && settings != null) {
      _initializedForm = true;
      _serviceFeeController.text = settings.defaultServiceFeePercentage
          .toStringAsFixed(2);
      _acceptsQrCodeOrders = settings.acceptsQrCodeOrders;
      _acceptsWaiterCall = settings.acceptsWaiterCall;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações operacionais'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: state.isLoading
                ? null
                : () {
                    _initializedForm = false;
                    ref
                        .read(restaurantSettingsViewModelProvider.notifier)
                        .load();
                  },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading && settings == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.errorMessage != null) ...[
                      _ErrorBanner(message: state.errorMessage!),
                      const SizedBox(height: 16),
                    ],
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _serviceFeeController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9,.]'),
                                  ),
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Taxa de serviço padrão (%)',
                                  hintText: 'Ex: 10',
                                  prefixIcon: Icon(Icons.percent_rounded),
                                ),
                                validator: (value) {
                                  final number = _parseMoney(value ?? '');

                                  if (number == null) {
                                    return 'Informe uma taxa válida.';
                                  }

                                  if (number < 0) {
                                    return 'A taxa não pode ser negativa.';
                                  }

                                  if (number > 100) {
                                    return 'A taxa não pode ser maior que 100%.';
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                value: _acceptsQrCodeOrders,
                                title: const Text(
                                  'Aceitar pedidos pelo QR Code',
                                ),
                                subtitle: const Text(
                                  'Quando desligado, o cliente ainda vê o cardápio, mas não consegue criar pedido.',
                                ),
                                onChanged: state.isSaving
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _acceptsQrCodeOrders = value;
                                        });
                                      },
                              ),
                              const Divider(),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                value: _acceptsWaiterCall,
                                title: const Text(
                                  'Aceitar chamada de garçom pelo QR Code',
                                ),
                                subtitle: const Text(
                                  'Quando desligado, o botão de atendimento fica oculto ou bloqueado no cardápio público.',
                                ),
                                onChanged: state.isSaving
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _acceptsWaiterCall = value;
                                        });
                                      },
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: state.isSaving ? null : _save,
                                  icon: state.isSaving
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.save_rounded),
                                  label: const Text('Salvar configurações'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _save() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    final success = await ref
        .read(restaurantSettingsViewModelProvider.notifier)
        .update(
          defaultServiceFeePercentage:
              _parseMoney(_serviceFeeController.text) ?? 0,
          acceptsQrCodeOrders: _acceptsQrCodeOrders,
          acceptsWaiterCall: _acceptsWaiterCall,
        );

    if (!mounted || !success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configurações salvas com sucesso.')),
    );
  }

  double? _parseMoney(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.'));
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
