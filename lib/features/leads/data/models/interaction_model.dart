import '../../domain/entities/interaction.dart';

class InteractionModel {
  static Interaction fromJson(Map<String, dynamic> json) {
    return Interaction(
      id: json['id'] as String,
      leadId: json['lead_id'] as String,
      message: json['message'] as String,
      direction: json['direction'] == 'outbound'
          ? InteractionDirection.outbound
          : InteractionDirection.system,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static String directionToDb(InteractionDirection direction) {
    return switch (direction) {
      InteractionDirection.outbound => 'outbound',
      InteractionDirection.system => 'system',
    };
  }
}
