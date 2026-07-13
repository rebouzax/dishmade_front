class CloseOrderAccountRequest {
  final double discountAmount;
  final double serviceFeeAmount;

  const CloseOrderAccountRequest({
    required this.discountAmount,
    required this.serviceFeeAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'discountAmount': discountAmount,
      'serviceFeeAmount': serviceFeeAmount,
    };
  }
}
