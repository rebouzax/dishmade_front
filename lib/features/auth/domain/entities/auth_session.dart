import 'auth_user.dart';

class AuthSession {
  final String accessToken;
  final DateTime expiresAt;
  final AuthUser user;

  const AuthSession({
    required this.accessToken,
    required this.expiresAt,
    required this.user,
  });

  bool get isExpired {
    return expiresAt.toUtc().isBefore(DateTime.now().toUtc());
  }

  bool get isValid {
    return accessToken.isNotEmpty && !isExpired;
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'expiresAt': expiresAt.toIso8601String(),
      'user': user.toJson(),
    };
  }

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['accessToken']?.toString() ?? '',
      expiresAt: DateTime.parse(json['expiresAt'].toString()),
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
