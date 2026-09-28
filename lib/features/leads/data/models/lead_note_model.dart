import '../../domain/entities/lead_note.dart';

class LeadNoteModel {
  static LeadNote fromJson(Map<String, dynamic> json) {
    return LeadNote(
      id: json['id'].toString(),
      leadId: json['lead_id'] as String,
      text: json['note'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}