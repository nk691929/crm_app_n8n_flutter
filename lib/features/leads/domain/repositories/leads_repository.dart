import '../entities/lead.dart';

abstract class LeadsRepository {
  Stream<List<Lead>> watchLeads();
  Future<void> updateStatus({required String leadId, required LeadStatus status});
  Future<void> updatePriority({required String leadId, required LeadPriority priority});
  Future<void> addNote({required String leadId, required String note});
}