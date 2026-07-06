enum ServiceRequestType { callWaiter, requestBill, needHelp, other }

extension ServiceRequestTypeExtension on ServiceRequestType {
  String get apiValue {
    switch (this) {
      case ServiceRequestType.callWaiter:
        return 'CallWaiter';
      case ServiceRequestType.requestBill:
        return 'RequestBill';
      case ServiceRequestType.needHelp:
        return 'NeedHelp';
      case ServiceRequestType.other:
        return 'Other';
    }
  }

  String get label {
    switch (this) {
      case ServiceRequestType.callWaiter:
        return 'Chamar garçom';
      case ServiceRequestType.requestBill:
        return 'Pedir conta';
      case ServiceRequestType.needHelp:
        return 'Preciso de ajuda';
      case ServiceRequestType.other:
        return 'Outro';
    }
  }

  static ServiceRequestType fromApi(dynamic value) {
    final text = value?.toString();

    switch (text) {
      case '1':
      case 'CallWaiter':
        return ServiceRequestType.callWaiter;
      case '2':
      case 'RequestBill':
        return ServiceRequestType.requestBill;
      case '3':
      case 'NeedHelp':
        return ServiceRequestType.needHelp;
      case '4':
      case 'Other':
        return ServiceRequestType.other;
      default:
        return ServiceRequestType.other;
    }
  }
}
