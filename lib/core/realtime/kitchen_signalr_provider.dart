import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'kitchen_signalr_service.dart';

final kitchenSignalRServiceProvider = Provider<KitchenSignalRService>((ref) {
  final service = KitchenSignalRService();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});
