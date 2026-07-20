import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/realtime/kitchen_realtime_controller.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/service_request.dart';
import '../../domain/enums/service_request_status.dart';
import '../../domain/enums/service_request_type.dart';
import '../viewmodels/service_requests_viewmodel.dart';

class ServiceRequestsPage extends ConsumerStatefulWidget {
  const ServiceRequestsPage({super.key});

  @override
  ConsumerState<ServiceRequestsPage> createState() =>
      _ServiceRequestsPageState();
}

class _ServiceRequestsPageState extends ConsumerState<ServiceRequestsPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(serviceRequestsViewModelProvider.notifier).loadInitial();
      ref.read(kitchenRealtimeControllerProvider.notifier).connect();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(serviceRequestsViewModelProvider);
    final viewModel = ref.read(serviceRequestsViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitações'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: state.isLoading ? null : viewModel.loadInitial,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: viewModel.loadInitial,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: _Filters(
                    status: state.statusFilter,
                    type: state.typeFilter,
                    onStatusChanged: viewModel.setStatusFilter,
                    onTypeChanged: viewModel.setTypeFilter,
                  ),
                ),
              ),
              if (state.errorMessage != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: _ErrorBanner(message: state.errorMessage!),
                  ),
                ),
              if (state.isLoading && state.requests.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.requests.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: Text('Nenhuma solicitação encontrada.')),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == state.requests.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Center(
                              child: OutlinedButton.icon(
                                onPressed: state.isLoading
                                    ? null
                                    : viewModel.loadNextPage,
                                icon: const Icon(Icons.expand_more_rounded),
                                label: const Text('Carregar mais'),
                              ),
                            ),
                          );
                        }

                        final request = state.requests[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ServiceRequestCard(
                            request: request,
                            isSaving: state.isSaving,
                            onStart: () => _start(request),
                            onResolve: () => _resolve(request),
                            onCancel: () => _cancel(request),
                          ),
                        );
                      },
                      childCount:
                          state.requests.length + (state.hasNextPage ? 1 : 0),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _start(ServiceRequest request) async {
    final success = await ref
        .read(serviceRequestsViewModelProvider.notifier)
        .start(request.id);

    if (!mounted || !success) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Atendimento iniciado.')));
  }

  Future<void> _resolve(ServiceRequest request) async {
    final success = await ref
        .read(serviceRequestsViewModelProvider.notifier)
        .resolve(request.id);

    if (!mounted || !success) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Solicitação resolvida.')));
  }

  Future<void> _cancel(ServiceRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancelar solicitação'),
          content: const Text('Deseja cancelar esta solicitação?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Não'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Cancelar solicitação'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final success = await ref
        .read(serviceRequestsViewModelProvider.notifier)
        .cancel(request.id);

    if (!mounted || !success) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Solicitação cancelada.')));
  }
}

class _Filters extends StatelessWidget {
  final ServiceRequestStatus? status;
  final ServiceRequestType? type;
  final ValueChanged<ServiceRequestStatus?> onStatusChanged;
  final ValueChanged<ServiceRequestType?> onTypeChanged;

  const _Filters({
    required this.status,
    required this.type,
    required this.onStatusChanged,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ChoiceChip(
              selected: status == null,
              label: const Text('Todos status'),
              onSelected: (_) => onStatusChanged(null),
            ),
            ...ServiceRequestStatus.values.map(
              (item) => ChoiceChip(
                selected: status == item,
                label: Text(item.label),
                onSelected: (_) => onStatusChanged(item),
              ),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              selected: type == null,
              label: const Text('Todos tipos'),
              onSelected: (_) => onTypeChanged(null),
            ),
            ...ServiceRequestType.values.map(
              (item) => ChoiceChip(
                selected: type == item,
                label: Text(item.label),
                onSelected: (_) => onTypeChanged(item),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceRequestCard extends StatelessWidget {
  final ServiceRequest request;
  final bool isSaving;
  final VoidCallback onStart;
  final VoidCallback onResolve;
  final VoidCallback onCancel;

  const _ServiceRequestCard({
    required this.request,
    required this.isSaving,
    required this.onStart,
    required this.onResolve,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(request.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  child: const Icon(
                    Icons.room_service_rounded,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Mesa ${request.tableNumber}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    request.status.label,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              request.type.label,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            if (request.message != null &&
                request.message!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                request.message!,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Criado em: ${DateFormatter.formatDateTime(request.createdAt)}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (request.status.canStart)
                  OutlinedButton.icon(
                    onPressed: isSaving ? null : onStart,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Iniciar'),
                  ),
                if (request.status.canResolve)
                  FilledButton.icon(
                    onPressed: isSaving ? null : onResolve,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Resolver'),
                  ),
                if (request.status.canCancel)
                  TextButton.icon(
                    onPressed: isSaving ? null : onCancel,
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Cancelar'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(ServiceRequestStatus status) {
    switch (status) {
      case ServiceRequestStatus.pending:
        return AppColors.warning;
      case ServiceRequestStatus.inProgress:
        return AppColors.primary;
      case ServiceRequestStatus.resolved:
        return AppColors.success;
      case ServiceRequestStatus.canceled:
        return AppColors.textSecondary;
    }
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
