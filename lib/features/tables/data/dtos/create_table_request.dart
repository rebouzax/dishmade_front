class CreateTableRequest {
  final int number;

  const CreateTableRequest({required this.number});

  Map<String, dynamic> toJson() {
    return {'number': number};
  }
}
