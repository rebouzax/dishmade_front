class AdminClient {
  final String userId;
  final String userName;
  final String email;
  final bool isActive;
  final String restaurantId;
  final String restaurantName;
  final String? restaurantDocument;
  final bool restaurantIsActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminClient({
    required this.userId,
    required this.userName,
    required this.email,
    required this.isActive,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantDocument,
    required this.restaurantIsActive,
    required this.createdAt,
    required this.updatedAt,
  });
}
