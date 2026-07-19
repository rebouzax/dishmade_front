import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/order_receipt.dart';
import '../../domain/enums/payment_method.dart';
import '../../domain/enums/payment_status.dart';
import '../viewmodels/order_checkout_viewmodel.dart';

class OrderCheckoutPage extends ConsumerStatefulWidget {
  final String orderId;
  final int? initialTableNumber;

  const OrderCheckoutPage({
    super.key,
    required this.orderId,
    this.initialTableNumber,
  });

  @override
  ConsumerState<OrderCheckoutPage> createState() => _OrderCheckoutPageState();
}

class _OrderCheckoutPageState extends ConsumerState<OrderCheckoutPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(orderCheckoutViewModelProvider.notifier)
          .loadReceipt(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderCheckoutViewModelProvider);
    final viewModel = ref.read(orderCheckoutViewModelProvider.notifier);
    final receipt = state.receipt;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialTableNumber == null
              ? 'Fechamento de conta'
              : 'Fechamento - Mesa ${widget.initialTableNumber}',
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar recibo',
            onPressed: state.isLoading
                ? null
                : () => viewModel.loadReceipt(widget.orderId),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => viewModel.loadReceipt(widget.orderId),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (state.isLoading && receipt == null)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.errorMessage != null && receipt == null)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                )
              else if (receipt == null)
                const SliverFillRemaining(
                  child: Center(child: Text('Recibo não encontrado.')),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: _ReceiptSummaryCard(receipt: receipt),
                  ),
                ),
                if (state.errorMessage != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: _ErrorBanner(message: state.errorMessage!),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: _ActionsCard(
                      receipt: receipt,
                      isSaving: state.isSaving,
                      onCloseAccount: _openCloseAccountDialog,
                      onRegisterPayment: _openRegisterPaymentDialog,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: _ItemsCard(receipt: receipt),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    child: _PaymentsCard(receipt: receipt),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openCloseAccountDialog() async {
    final result = await showDialog<_CloseAccountResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const _CloseAccountDialog();
      },
    );

    if (result == null) return;

    final success = await ref
        .read(orderCheckoutViewModelProvider.notifier)
        .closeAccount(
          orderId: widget.orderId,
          discountAmount: result.discountAmount,
          serviceFeeAmount: result.serviceFeeAmount,
          useDefaultServiceFee: result.useDefaultServiceFee,
        );

    if (!mounted || !success) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Conta fechada com sucesso.')));
  }

  Future<void> _openRegisterPaymentDialog() async {
    final receipt = ref.read(orderCheckoutViewModelProvider).receipt;

    final result = await showDialog<_RegisterPaymentResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _RegisterPaymentDialog(
          suggestedAmount: receipt?.remainingAmount ?? 0,
        );
      },
    );

    if (result == null) return;

    final success = await ref
        .read(orderCheckoutViewModelProvider.notifier)
        .registerPayment(
          orderId: widget.orderId,
          method: result.method,
          amount: result.amount,
          notes: result.notes,
        );

    if (!mounted || !success) return;

    final updatedReceipt = ref.read(orderCheckoutViewModelProvider).receipt;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updatedReceipt?.paymentStatus == PaymentStatus.paid
              ? 'Pagamento concluído. Pedido entregue e mesa liberada.'
              : 'Pagamento registrado com sucesso.',
        ),
      ),
    );
  }
}

class _ReceiptSummaryCard extends StatelessWidget {
  final OrderReceipt receipt;

  const _ReceiptSummaryCard({required this.receipt});

  @override
  Widget build(BuildContext context) {
    final isPaid = receipt.paymentStatus == PaymentStatus.paid;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Mesa ${receipt.tableNumber}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _StatusBadge(
                  label: receipt.paymentStatus.label,
                  color: isPaid ? AppColors.success : AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _AmountRow(label: 'Subtotal', value: receipt.subtotal),
            _AmountRow(
              label: 'Taxa de serviço',
              value: receipt.serviceFeeAmount,
            ),
            _AmountRow(label: 'Desconto', value: -receipt.discountAmount),
            const Divider(height: 26),
            _AmountRow(
              label: 'Total final',
              value: receipt.finalTotal,
              isStrong: true,
            ),
            _AmountRow(label: 'Valor pago', value: receipt.paidAmount),
            _AmountRow(
              label: 'Falta pagar',
              value: receipt.remainingAmount,
              isStrong: true,
            ),
            if (receipt.closedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Conta fechada em: ${DateFormatter.formatDateTime(receipt.closedAt!)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
            if (receipt.paidAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Pago em: ${DateFormatter.formatDateTime(receipt.paidAt!)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionsCard extends StatelessWidget {
  final OrderReceipt receipt;
  final bool isSaving;
  final VoidCallback onCloseAccount;
  final VoidCallback onRegisterPayment;

  const _ActionsCard({
    required this.receipt,
    required this.isSaving,
    required this.onCloseAccount,
    required this.onRegisterPayment,
  });

  @override
  Widget build(BuildContext context) {
    final isClosed = receipt.closedAt != null;
    final isPaid = receipt.paymentStatus == PaymentStatus.paid;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              onPressed: isSaving || isClosed ? null : onCloseAccount,
              icon: const Icon(Icons.lock_rounded),
              label: Text(isClosed ? 'Conta fechada' : 'Fechar conta'),
            ),
            OutlinedButton.icon(
              onPressed: isSaving || !isClosed || isPaid
                  ? null
                  : onRegisterPayment,
              icon: const Icon(Icons.payments_rounded),
              label: const Text('Registrar pagamento'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  final OrderReceipt receipt;

  const _ItemsCard({required this.receipt});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Itens do pedido',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            if (receipt.items.isEmpty)
              const Text('Nenhum item encontrado.')
            else
              ...receipt.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.quantity}x ${item.dishName}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(item.total),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                      if (item.options.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        ...item.options.map(
                          (option) => Text(
                            '+ ${option.name} (${CurrencyFormatter.format(option.additionalPrice)})',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                      if (item.notes != null &&
                          item.notes!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Obs: ${item.notes}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PaymentsCard extends StatelessWidget {
  final OrderReceipt receipt;

  const _PaymentsCard({required this.receipt});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pagamentos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            if (receipt.payments.isEmpty)
              const Text('Nenhum pagamento registrado.')
            else
              ...receipt.payments.map(
                (payment) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.success.withOpacity(0.12),
                        child: const Icon(
                          Icons.check_rounded,
                          color: AppColors.success,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              payment.method.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              DateFormatter.formatDateTime(payment.createdAt),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            if (payment.notes != null &&
                                payment.notes!.trim().isNotEmpty)
                              Text(
                                payment.notes!,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(payment.amount),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isStrong;

  const _AmountRow({
    required this.label,
    required this.value,
    this.isStrong = false,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: isStrong ? 17 : 14,
      fontWeight: isStrong ? FontWeight.w900 : FontWeight.w600,
      color: AppColors.textPrimary,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: textStyle)),
          Text(CurrencyFormatter.format(value), style: textStyle),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
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

class _CloseAccountResult {
  final double discountAmount;
  final double? serviceFeeAmount;
  final bool useDefaultServiceFee;

  const _CloseAccountResult({
    required this.discountAmount,
    required this.serviceFeeAmount,
    required this.useDefaultServiceFee,
  });
}

class _CloseAccountDialog extends StatefulWidget {
  const _CloseAccountDialog();

  @override
  State<_CloseAccountDialog> createState() => _CloseAccountDialogState();
}

class _CloseAccountDialogState extends State<_CloseAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _discountController = TextEditingController(text: '0');
  final _serviceFeeController = TextEditingController(text: '0');

  bool _useDefaultServiceFee = true;

  @override
  void dispose() {
    _discountController.dispose();
    _serviceFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Fechar conta'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _discountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Desconto',
                    prefixIcon: Icon(Icons.discount_rounded),
                  ),
                  validator: _validateNonNegativeMoney,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _useDefaultServiceFee,
                  title: const Text('Usar taxa de serviço padrão'),
                  subtitle: const Text(
                    'O backend calculará a taxa com base na configuração do restaurante.',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _useDefaultServiceFee = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _serviceFeeController,
                  enabled: !_useDefaultServiceFee,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Taxa de serviço manual',
                    prefixIcon: Icon(Icons.room_service_rounded),
                  ),
                  validator: (value) {
                    if (_useDefaultServiceFee) return null;

                    return _validateNonNegativeMoney(value);
                  },
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
        FilledButton(onPressed: _submit, child: const Text('Fechar conta')),
      ],
    );
  }

  String? _validateNonNegativeMoney(String? value) {
    final number = _parseMoney(value ?? '');

    if (number == null) {
      return 'Informe um valor válido.';
    }

    if (number < 0) {
      return 'O valor não pode ser negativo.';
    }

    return null;
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    Navigator.of(context).pop(
      _CloseAccountResult(
        discountAmount: _parseMoney(_discountController.text) ?? 0,
        serviceFeeAmount: _useDefaultServiceFee
            ? null
            : _parseMoney(_serviceFeeController.text) ?? 0,
        useDefaultServiceFee: _useDefaultServiceFee,
      ),
    );
  }

  double? _parseMoney(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }
}

class _RegisterPaymentResult {
  final PaymentMethod method;
  final double amount;
  final String? notes;

  const _RegisterPaymentResult({
    required this.method,
    required this.amount,
    this.notes,
  });
}

class _RegisterPaymentDialog extends StatefulWidget {
  final double suggestedAmount;

  const _RegisterPaymentDialog({required this.suggestedAmount});

  @override
  State<_RegisterPaymentDialog> createState() => _RegisterPaymentDialogState();
}

class _RegisterPaymentDialogState extends State<_RegisterPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  PaymentMethod _method = PaymentMethod.pix;

  @override
  void initState() {
    super.initState();

    _amountController.text = widget.suggestedAmount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar pagamento'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<PaymentMethod>(
                  initialValue: _method,
                  decoration: const InputDecoration(
                    labelText: 'Método',
                    prefixIcon: Icon(Icons.payment_rounded),
                  ),
                  items: PaymentMethod.values
                      .map(
                        (method) => DropdownMenuItem(
                          value: method,
                          child: Text(method.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _method = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Valor',
                    prefixIcon: Icon(Icons.attach_money_rounded),
                  ),
                  validator: (value) {
                    final number = _parseMoney(value ?? '');

                    if (number == null) {
                      return 'Informe um valor válido.';
                    }

                    if (number <= 0) {
                      return 'O valor deve ser maior que zero.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: 'Observação',
                    hintText: 'Ex: Pagamento final',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
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
        FilledButton(onPressed: _submit, child: const Text('Registrar')),
      ],
    );
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    Navigator.of(context).pop(
      _RegisterPaymentResult(
        method: _method,
        amount: _parseMoney(_amountController.text) ?? 0,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      ),
    );
  }

  double? _parseMoney(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }
}
