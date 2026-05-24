class UpdateTableRequest {
  final int number;

  const UpdateTableRequest({required this.number});

  Map<String, dynamic> toJson() {
    return {'number': number};
  }
}
