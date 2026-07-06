import '../../domain/enums/service_request_type.dart';

class CreatePublicServiceRequestRequest {
  final String restaurantSlug;
  final int tableNumber;
  final ServiceRequestType type;
  final String? message;

  const CreatePublicServiceRequestRequest({
    required this.restaurantSlug,
    required this.tableNumber,
    required this.type,
    this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'restaurantSlug': restaurantSlug,
      'tableNumber': tableNumber,
      'type': type.apiValue,
      if (message != null && message!.trim().isNotEmpty)
        'message': message!.trim(),
    };
  }
}
