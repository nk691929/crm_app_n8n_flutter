import '../../domain/entities/lead.dart';
import '../../domain/repositories/leads_repository.dart';
import '../datasources/leads_remote_datasource.dart';

class LeadsRepositoryImpl implements LeadsRepository {
  final LeadsRemoteDataSource _dataSource;

  LeadsRepositoryImpl(this._dataSource);

  @override
  Stream<List<Lead>> watchLeads() => _dataSource.watchLeads();

  @override
  Future<void> updateStatus({required String leadId, required LeadStatus status}) {
    return _dataSource.updateStatus(leadId: leadId, statusLabel: status.label);
  }

  @override
  Future<void> updatePriority({required String leadId, required LeadPriority priority}) {
    return _dataSource.updatePriority(leadId: leadId, priorityLabel: priority.label);
  }

  @override
  Future<void> addNote({required String leadId, required String note}) {
    return _dataSource.addNote(leadId: leadId, note: note);
  }
}