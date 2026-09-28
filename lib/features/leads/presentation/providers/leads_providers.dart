import 'package:crm_app/core/error/result.dart';
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

class LeadsController {
  final LeadsRepository _repository;

  LeadsController(this._repository);

  Future<Result<void>> updateStatus({
    required String leadId,
    required LeadStatus status,
  }) => _repository.updateStatus(leadId: leadId, status: status);

  Future<Result<void>> updatePriority({
    required String leadId,
    required LeadPriority priority,
  }) => _repository.updatePriority(leadId: leadId, priority: priority);

  Future<Result<void>> addNote({
    required String leadId,
    required String note,
  }) => _repository.addNote(leadId: leadId, note: note);
}

final leadsControllerProvider = Provider<LeadsController>((ref) {
  final repository = ref.watch(leadsRepositoryProvider);
  return LeadsController(repository);
});
