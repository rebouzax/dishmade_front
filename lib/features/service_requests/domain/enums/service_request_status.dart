enum ServiceRequestStatus { pending, inProgress, resolved, canceled }

extension ServiceRequestStatusExtension on ServiceRequestStatus {
  String get apiValue {
    switch (this) {
      case ServiceRequestStatus.pending:
        return 'Pending';
      case ServiceRequestStatus.inProgress:
        return 'InProgress';
      case ServiceRequestStatus.resolved:
        return 'Resolved';
      case ServiceRequestStatus.canceled:
        return 'Canceled';
    }
  }

  String get label {
    switch (this) {
      case ServiceRequestStatus.pending:
        return 'Pendente';
      case ServiceRequestStatus.inProgress:
        return 'Em atendimento';
      case ServiceRequestStatus.resolved:
        return 'Resolvida';
      case ServiceRequestStatus.canceled:
        return 'Cancelada';
    }
  }

  bool get canStart => this == ServiceRequestStatus.pending;

  bool get canResolve {
    return this == ServiceRequestStatus.pending ||
        this == ServiceRequestStatus.inProgress;
  }

  bool get canCancel {
    return this == ServiceRequestStatus.pending ||
        this == ServiceRequestStatus.inProgress;
  }

  static ServiceRequestStatus fromApi(dynamic value) {
    final text = value?.toString();
    switch (text) {
      case '1':
      case 'Pending':
        return ServiceRequestStatus.pending;
      case '2':
      case 'InProgress':
        return ServiceRequestStatus.inProgress;
      case '3':
      case 'Resolved':
        return ServiceRequestStatus.resolved;
      case '4':
      case 'Canceled':
        return ServiceRequestStatus.canceled;
      default:
        return ServiceRequestStatus.pending;
    }
  }
}
