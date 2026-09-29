import 'package:crm_app/core/error/result.dart';
import 'package:crm_app/features/leads/domain/entities/interaction.dart';
import 'package:crm_app/features/leads/domain/entities/lead_note.dart';

import '../entities/lead.dart';

abstract class LeadsRepository {
  Stream<List<Lead>> watchLeads();

  Future<Result<void>> updateStatus({
    required String leadId,
    required LeadStatus status,
    DateTime? nextFollowUpAt,
    bool clearNextFollowUp = false,
    int? followUpCount,
  });
  Future<Result<void>> updatePriority({
    required String leadId,
    required LeadPriority priority,
  });
  Future<Result<void>> addNote({required String leadId, required String note});
  Future<Result<List<LeadNote>>> getNotes(String leadId);
  Future<Result<List<Interaction>>> getInteractions(String leadId);
}
