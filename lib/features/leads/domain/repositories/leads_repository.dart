import 'package:crm_app/core/error/result.dart';

import '../entities/lead.dart';

abstract class LeadsRepository {
  Stream<List<Lead>> watchLeads();

  Future<Result<void>> updateStatus({required String leadId, required LeadStatus status});
  Future<Result<void>> updatePriority({required String leadId, required LeadPriority priority});
  Future<Result<void>> addNote({required String leadId, required String note});
}