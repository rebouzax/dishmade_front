import '../../domain/entities/admin_client.dart';

class AdminClientDto {
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

  const AdminClientDto({
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

  factory AdminClientDto.fromJson(Map<String, dynamic> json) {
    return AdminClientDto(
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      isActive: json['isActive'] as bool? ?? false,
      restaurantId: json['restaurantId']?.toString() ?? '',
      restaurantName: json['restaurantName']?.toString() ?? '',
      restaurantDocument: json['restaurantDocument']?.toString(),
      restaurantIsActive: json['restaurantIsActive'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  AdminClient toEntity() {
    return AdminClient(
      userId: userId,
      userName: userName,
      email: email,
      isActive: isActive,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      restaurantDocument: restaurantDocument,
      restaurantIsActive: restaurantIsActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
