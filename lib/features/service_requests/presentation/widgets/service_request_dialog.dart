import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/enums/service_request_type.dart';
import '../viewmodels/public_service_request_viewmodel.dart';

class ServiceRequestDialog extends ConsumerStatefulWidget {
  final String restaurantSlug;
  final int tableNumber;

  const ServiceRequestDialog({
    super.key,
    required this.restaurantSlug,
    required this.tableNumber,
  });

  @override
  ConsumerState<ServiceRequestDialog> createState() =>
      _ServiceRequestDialogState();
}

class _ServiceRequestDialogState extends ConsumerState<ServiceRequestDialog> {
  ServiceRequestType _selectedType = ServiceRequestType.callWaiter;
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await ref
        .read(publicServiceRequestViewModelProvider.notifier)
        .sendRequest(
          restaurantSlug: widget.restaurantSlug,
          tableNumber: widget.tableNumber,
          type: _selectedType,
          message: _messageController.text.trim().isEmpty
              ? null
              : _messageController.text.trim(),
        );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação enviada com sucesso.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(publicServiceRequestViewModelProvider).errorMessage ??
                'Erro ao enviar solicitação.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(publicServiceRequestViewModelProvider);

    return AlertDialog(
      title: const Text('Solicitar atendimento'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selecione o tipo de solicitação:'),
            const SizedBox(height: 12),
            DropdownButtonFormField<ServiceRequestType>(
              initialValue: _selectedType,
              items: ServiceRequestType.values
                  .map(
                    (type) =>
                        DropdownMenuItem(value: type, child: Text(type.label)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Mensagem (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                state.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: state.isSending
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: state.isSending ? null : _submit,
          child: state.isSending
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enviar'),
        ),
      ],
    );
  }
}
