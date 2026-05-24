import 'package:intl/intl.dart';

abstract final class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  static String format(double value) {
    return _formatter.format(value);
  }
}
