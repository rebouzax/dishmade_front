import '../../domain/entities/public_order_open_session.dart';
import 'public_order_dto.dart';

class PublicOrderOpenSessionDto {
  final bool wasCreated;
  final bool wasRecovered;
  final PublicOrderDto order;

  const PublicOrderOpenSessionDto({
    required this.wasCreated,
    required this.wasRecovered,
    required this.order,
  });

  factory PublicOrderOpenSessionDto.fromJson(Map<String, dynamic> json) {
    final rawOrder = json['order'];

    return PublicOrderOpenSessionDto(
      wasCreated: json['wasCreated'] as bool? ?? false,
      wasRecovered: json['wasRecovered'] as bool? ?? false,
      order: PublicOrderDto.fromJson(
        rawOrder is Map<String, dynamic> ? rawOrder : <String, dynamic>{},
      ),
    );
  }

  PublicOrderOpenSession toEntity() {
    return PublicOrderOpenSession(
      wasCreated: wasCreated,
      wasRecovered: wasRecovered,
      order: order.toEntity(),
    );
  }
}
