import 'package:equatable/equatable.dart';

enum InteractionDirection { outbound, system }

class Interaction extends Equatable {
  final String id;
  final String leadId;
  final String message;
  final InteractionDirection direction;
  final DateTime createdAt;

  const Interaction({
    required this.id,
    required this.leadId,
    required this.message,
    required this.direction,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, leadId, message, direction, createdAt];
}
