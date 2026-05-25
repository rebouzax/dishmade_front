import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/user_role.dart';

class AuthResponseDto {
  final String accessToken;
  final DateTime expiresAt;
  final AuthUser user;

  const AuthResponseDto({
    required this.accessToken,
    required this.expiresAt,
    required this.user,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>;

    return AuthResponseDto(
      accessToken: json['accessToken']?.toString() ?? '',
      expiresAt: DateTime.parse(json['expiresAt'].toString()),
      user: AuthUser(
        id: userJson['id']?.toString() ?? '',
        name: userJson['name']?.toString() ?? '',
        email: userJson['email']?.toString() ?? '',
        role: UserRole.fromString(userJson['role']?.toString()),
        restaurantId: userJson['restaurantId']?.toString(),
        restaurantName: userJson['restaurantName']?.toString(),
      ),
    );
  }

  AuthSession toEntity() {
    return AuthSession(
      accessToken: accessToken,
      expiresAt: expiresAt,
      user: user,
    );
  }
}
