import 'user_role.dart';

class AuthUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? restaurantId;
  final String? restaurantName;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.restaurantId,
    this.restaurantName,
  });

  bool get isPlatformAdmin => role.isPlatformAdmin;

  bool get isClient => role.isClient;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.value,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
    };
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: UserRole.fromString(json['role']?.toString()),
      restaurantId: json['restaurantId']?.toString(),
      restaurantName: json['restaurantName']?.toString(),
    );
  }
}
