import 'package:flutter/foundation.dart';

abstract final class Logger {
  static void logError(String message, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('$message\n$error\n$stackTrace');
    }
  }
}
