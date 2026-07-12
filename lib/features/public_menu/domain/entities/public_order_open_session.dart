import 'public_order.dart';

class PublicOrderOpenSession {
  final bool wasCreated;
  final bool wasRecovered;
  final PublicOrder order;

  const PublicOrderOpenSession({
    required this.wasCreated,
    required this.wasRecovered,
    required this.order,
  });
}
