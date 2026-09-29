import 'package:crm_app/core/error/result.dart';
import 'package:crm_app/features/leads/domain/entities/interaction.dart';
import 'package:crm_app/features/leads/domain/entities/lead.dart';
import 'package:crm_app/features/leads/domain/entities/lead_note.dart';
import 'package:crm_app/features/leads/domain/repositories/leads_repository.dart';

/// A hand-written fake — no mocking framework needed for a use case
/// this small. Records the last call so tests can assert on it.
class FakeLeadsRepository implements LeadsRepository {
  Result<void> updateStatusResult = const Success(null);

  String? lastUpdatedLeadId;
  LeadStatus? lastStatus;
  DateTime? lastNextFollowUpAt;
  bool lastClearNextFollowUp = false;
  int? lastFollowUpCount;

  @override
  Future<Result<void>> updateStatus({
    required String leadId,
    required LeadStatus status,
    DateTime? nextFollowUpAt,
    bool clearNextFollowUp = false,
    int? followUpCount,
  }) async {
    lastUpdatedLeadId = leadId;
    lastStatus = status;
    lastNextFollowUpAt = nextFollowUpAt;
    lastClearNextFollowUp = clearNextFollowUp;
    lastFollowUpCount = followUpCount;
    return updateStatusResult;
  }

  // --- Unused by these tests, but required by the interface ---

  @override
  Stream<List<Lead>> watchLeads() => const Stream.empty();

  @override
  Future<Result<void>> updatePriority({
    required String leadId,
    required LeadPriority priority,
  }) async => const Success(null);

  @override
  Future<Result<void>> addNote({
    required String leadId,
    required String note,
  }) async => const Success(null);

  @override
  Future<Result<List<LeadNote>>> getNotes(String leadId) async =>
      const Success([]);

  @override
  Future<Result<List<Interaction>>> getInteractions(String leadId) async =>
      const Success([]);
}
