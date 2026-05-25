enum UserRole {
  platformAdmin('PlatformAdmin'),
  client('Client'),
  unknown('Unknown');

  final String value;

  const UserRole(this.value);

  static UserRole fromString(String? value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.unknown,
    );
  }

  bool get isPlatformAdmin => this == UserRole.platformAdmin;

  bool get isClient => this == UserRole.client;
}
