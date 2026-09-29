import 'package:equatable/equatable.dart';

class LeadNote extends Equatable {
  final String id;
  final String leadId;
  final String text;
  final DateTime createdAt;

  const LeadNote({
    required this.id,
    required this.leadId,
    required this.text,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, leadId, text, createdAt];
}
