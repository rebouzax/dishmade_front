class PublicOrderSession {
  final String restaurantSlug;
  final String orderId;
  final String accessCode;
  final int tableNumber;

  const PublicOrderSession({
    required this.restaurantSlug,
    required this.orderId,
    required this.accessCode,
    required this.tableNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'restaurantSlug': restaurantSlug,
      'orderId': orderId,
      'accessCode': accessCode,
      'tableNumber': tableNumber,
    };
  }

  factory PublicOrderSession.fromJson(Map<String, dynamic> json) {
    return PublicOrderSession(
      restaurantSlug: json['restaurantSlug']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      accessCode: json['accessCode']?.toString() ?? '',
      tableNumber: json['tableNumber'] as int? ?? 0,
    );
  }
}
