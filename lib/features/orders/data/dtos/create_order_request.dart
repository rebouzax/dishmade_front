class CreateOrderRequest {
  final String tableId;

  const CreateOrderRequest({required this.tableId});

  Map<String, dynamic> toJson() {
    return {'tableId': tableId};
  }
}
