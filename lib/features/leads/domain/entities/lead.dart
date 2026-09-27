import 'package:equatable/equatable.dart';

enum LeadStatus { newLead, contacted, qualified, won, lost }
enum LeadPriority { high, medium, low }

extension LeadStatusX on LeadStatus {
  String get label {
    switch (this) {
      case LeadStatus.newLead: return 'New';
      case LeadStatus.contacted: return 'Contacted';
      case LeadStatus.qualified: return 'Qualified';
      case LeadStatus.won: return 'Won';
      case LeadStatus.lost: return 'Lost';
    }
  }

  static LeadStatus fromLabel(String label) {
    return LeadStatus.values.firstWhere(
      (s) => s.label == label,
      orElse: () => LeadStatus.newLead,
    );
  }
}

extension LeadPriorityX on LeadPriority {
  String get label {
    switch (this) {
      case LeadPriority.high: return 'High';
      case LeadPriority.medium: return 'Medium';
      case LeadPriority.low: return 'Low';
    }
  }

  static LeadPriority fromLabel(String label) {
    return LeadPriority.values.firstWhere(
      (p) => p.label == label,
      orElse: () => LeadPriority.medium,
    );
  }
}

class Lead extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? serviceInterested;
  final String? budget;
  final String? message;
  final LeadStatus status;
  final LeadPriority priority;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastContactedAt;
  final DateTime? nextFollowUpAt;
  final int followUpCount;

  const Lead({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.serviceInterested,
    this.budget,
    this.message,
    required this.status,
    required this.priority,
    this.assignedTo,
    required this.createdAt,
    required this.updatedAt,
    this.lastContactedAt,
    this.nextFollowUpAt,
    required this.followUpCount,
  });

  Lead copyWith({
    LeadStatus? status,
    LeadPriority? priority,
    String? assignedTo,
  }) {
    return Lead(
      id: id,
      name: name,
      phone: phone,
      email: email,
      serviceInterested: serviceInterested,
      budget: budget,
      message: message,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastContactedAt: lastContactedAt,
      nextFollowUpAt: nextFollowUpAt,
      followUpCount: followUpCount,
    );
  }

  @override
  List<Object?> get props => [
        id, name, phone, email, serviceInterested, budget, message,
        status, priority, assignedTo, createdAt, updatedAt,
        lastContactedAt, nextFollowUpAt, followUpCount,
      ];
}