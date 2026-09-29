import 'package:crm_app/features/leads/domain/entities/lead.dart';

/// Builds a valid Lead with sensible defaults, so each test only
/// specifies the field it actually cares about.
Lead buildTestLead({
  String id = 'lead-1',
  String name = 'Test Lead',
  LeadStatus status = LeadStatus.newLead,
  LeadPriority priority = LeadPriority.medium,
}) {
  final now = DateTime(2026, 1, 1);
  return Lead(
    id: id,
    name: name,
    phone: '+920000000000',
    email: 'test@example.com',
    serviceInterested: 'Testing',
    budget: null,
    message: null,
    status: status,
    priority: priority,
    assignedTo: null,
    createdAt: now,
    updatedAt: now,
    lastContactedAt: null,
    nextFollowUpAt: null,
    followUpCount: 0,
  );
}