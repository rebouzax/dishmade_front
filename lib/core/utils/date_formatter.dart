class DateFormatter {
  const DateFormatter._();

  static String formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();

    final day = _twoDigits(local.day);
    final month = _twoDigits(local.month);
    final year = local.year.toString();

    final hour = _twoDigits(local.hour);
    final minute = _twoDigits(local.minute);

    return '$day/$month/$year $hour:$minute';
  }

  static String formatDate(DateTime dateTime) {
    final local = dateTime.toLocal();

    final day = _twoDigits(local.day);
    final month = _twoDigits(local.month);
    final year = local.year.toString();

    return '$day/$month/$year';
  }

  static String formatTime(DateTime dateTime) {
    final local = dateTime.toLocal();

    final hour = _twoDigits(local.hour);
    final minute = _twoDigits(local.minute);

    return '$hour:$minute';
  }

  static String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }
}
