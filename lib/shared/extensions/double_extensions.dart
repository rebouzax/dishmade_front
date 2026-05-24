extension DoubleExtensions on double {
  String toCurrency({String symbol = 'R\$'}) {
    return '$symbol${toStringAsFixed(2).replaceAll('.', ',')}';
  }

  bool get isPositive => this > 0;
  bool get isNegative => this < 0;
}
