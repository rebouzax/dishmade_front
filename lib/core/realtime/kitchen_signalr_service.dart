import 'dart:async';

import 'package:signalr_netcore/signalr_client.dart';

import '../config/env.dart';
import 'kitchen_realtime_events.dart';

typedef KitchenRealtimeCallback =
    void Function(String eventName, Map<String, dynamic> payload);

class KitchenSignalRService {
  HubConnection? _connection;
  bool _isConnecting = false;

  bool get isConnected => _connection != null;

  Future<void> connect({
    required Future<String?> Function() accessTokenFactory,
    required KitchenRealtimeCallback onEvent,
  }) async {
    if (_connection != null || _isConnecting) return;

    _isConnecting = true;

    try {
      final hubUrl = '${Env.apiBaseUrl}/hubs/kitchen';

      final connection = HubConnectionBuilder()
          .withUrl(
            hubUrl,
            options: HttpConnectionOptions(
              accessTokenFactory: () async {
                return await accessTokenFactory() ?? '';
              },
            ),
          )
          .build();

      for (final eventName in KitchenRealtimeEvents.all) {
        connection.on(eventName, (arguments) {
          final payload = _extractPayload(arguments);

          if (payload == null) return;

          onEvent(eventName, payload);
        });
      }

      await connection.start();

      _connection = connection;
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> disconnect() async {
    final connection = _connection;

    if (connection == null) return;

    _connection = null;

    await connection.stop();
  }

  Future<void> dispose() async {
    await disconnect();
  }

  Map<String, dynamic>? _extractPayload(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return null;

    final first = arguments.first;

    if (first is Map<String, dynamic>) {
      return first;
    }

    if (first is Map) {
      return first.map((key, value) => MapEntry(key.toString(), value));
    }

    return null;
  }
}
