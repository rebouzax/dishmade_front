class CreateAdminClientRequest {
  final String restaurantName;
  final String? restaurantDocument;
  final String userName;
  final String email;
  final String password;

  const CreateAdminClientRequest({
    required this.restaurantName,
    required this.restaurantDocument,
    required this.userName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'restaurantName': restaurantName,
      'restaurantDocument':
          restaurantDocument == null || restaurantDocument!.trim().isEmpty
          ? null
          : restaurantDocument!.trim(),
      'userName': userName,
      'email': email,
      'password': password,
    };
  }
}
