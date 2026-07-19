class CloseOrderAccountRequest {
  final double discountAmount;
  final double? serviceFeeAmount;
  final bool useDefaultServiceFee;

  const CloseOrderAccountRequest({
    required this.discountAmount,
    required this.serviceFeeAmount,
    required this.useDefaultServiceFee,
  });

  Map<String, dynamic> toJson() {
    return {
      'discountAmount': discountAmount,
      'serviceFeeAmount': serviceFeeAmount,
      'useDefaultServiceFee': useDefaultServiceFee,
    };
  }
}
