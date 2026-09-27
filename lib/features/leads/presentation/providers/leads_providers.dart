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

final leadsStreamProvider = StreamProvider<List<Lead>>((ref) {
  final repository = ref.watch(leadsRepositoryProvider);
  return repository.watchLeads();
});

class LeadsController {
  final LeadsRepository _repository;

  LeadsController(this._repository);

  Future<void> updateStatus({required String leadId, required LeadStatus status}) {
    return _repository.updateStatus(leadId: leadId, status: status);
  }

  Future<void> updatePriority({required String leadId, required LeadPriority priority}) {
    return _repository.updatePriority(leadId: leadId, priority: priority);
  }

  Future<void> addNote({required String leadId, required String note}) {
    return _repository.addNote(leadId: leadId, note: note);
  }
}

final leadsControllerProvider = Provider<LeadsController>((ref) {
  final repository = ref.watch(leadsRepositoryProvider);
  return LeadsController(repository);
});