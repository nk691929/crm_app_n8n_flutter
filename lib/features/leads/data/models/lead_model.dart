import '../../domain/entities/lead.dart';

class LeadModel {
  static Lead fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      serviceInterested: json['service_interested'] as String?,
      budget: json['budget'] as String?,
      message: json['message'] as String?,
      status: LeadStatusX.fromLabel(json['status'] as String? ?? 'New'),
      priority: LeadPriorityX.fromLabel(json['priority'] as String? ?? 'Medium'),
      assignedTo: json['assigned_to'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastContactedAt: json['last_contacted_at'] != null
          ? DateTime.parse(json['last_contacted_at'] as String)
          : null,
      nextFollowUpAt: json['next_follow_up_at'] != null
          ? DateTime.parse(json['next_follow_up_at'] as String)
          : null,
      followUpCount: json['follow_up_count'] as int? ?? 0,
    );
  }
}