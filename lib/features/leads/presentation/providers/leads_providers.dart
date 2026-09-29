import 'package:crm_app/core/error/result.dart';
import 'package:crm_app/features/leads/domain/entities/interaction.dart';
import 'package:crm_app/features/leads/domain/entities/lead_note.dart';
import 'package:crm_app/features/leads/domain/usecases/add_lead_note.dart';
import 'package:crm_app/features/leads/domain/usecases/update_lead_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/leads_remote_datasource.dart';
import '../../data/repositories/leads_repository_impl.dart';
import '../../domain/entities/lead.dart';
import '../../domain/repositories/leads_repository.dart';

final leadsRemoteDataSourceProvider = Provider<LeadsRemoteDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return LeadsRemoteDataSource(client);
});

final leadsRepositoryProvider = Provider<LeadsRepository>((ref) {
  final dataSource = ref.watch(leadsRemoteDataSourceProvider);
  return LeadsRepositoryImpl(dataSource);
});

final leadsStreamProvider = StreamProvider.autoDispose<List<Lead>>((ref) {
  final repository = ref.watch(leadsRepositoryProvider);
  return repository.watchLeads();
});

final updateLeadStatusUseCaseProvider = Provider<UpdateLeadStatus>((ref) {
  return UpdateLeadStatus(ref.watch(leadsRepositoryProvider));
});

final addLeadNoteUseCaseProvider = Provider<AddLeadNote>((ref) {
  return AddLeadNote(ref.watch(leadsRepositoryProvider));
});

class LeadsController {
  final UpdateLeadStatus _updateLeadStatus;
  final AddLeadNote _addLeadNote;
  final LeadsRepository _repository;

  LeadsController(this._updateLeadStatus, this._addLeadNote, this._repository);

  Future<Result<void>> updateStatus({
    required Lead lead,
    required LeadStatus newStatus,
  }) {
    return _updateLeadStatus(lead: lead, newStatus: newStatus);
  }

  Future<Result<void>> updatePriority({
    required String leadId,
    required LeadPriority priority,
  }) {
    return _repository.updatePriority(leadId: leadId, priority: priority);
  }

  Future<Result<void>> addNote({required String leadId, required String note}) {
    return _addLeadNote(leadId: leadId, note: note);
  }
}

final leadsControllerProvider = Provider<LeadsController>((ref) {
  return LeadsController(
    ref.watch(updateLeadStatusUseCaseProvider),
    ref.watch(addLeadNoteUseCaseProvider),
    ref.watch(leadsRepositoryProvider),
  );
});

final leadNotesProvider = FutureProvider.autoDispose
    .family<Result<List<LeadNote>>, String>(
      (ref, leadId) => ref.watch(leadsRepositoryProvider).getNotes(leadId),
    );

final leadInteractionsProvider = FutureProvider.autoDispose
    .family<Result<List<Interaction>>, String>(
      (ref, leadId) =>
          ref.watch(leadsRepositoryProvider).getInteractions(leadId),
    );
