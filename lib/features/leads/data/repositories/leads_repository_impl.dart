import 'package:crm_app/core/error/guard.dart';
import 'package:crm_app/core/error/result.dart';
import 'package:crm_app/features/leads/domain/entities/interaction.dart';
import 'package:crm_app/features/leads/domain/entities/lead_note.dart';

import '../../domain/entities/lead.dart';
import '../../domain/repositories/leads_repository.dart';
import '../datasources/leads_remote_datasource.dart';

class LeadsRepositoryImpl implements LeadsRepository {
  final LeadsRemoteDataSource _dataSource;

  LeadsRepositoryImpl(this._dataSource);

  @override
  Stream<List<Lead>> watchLeads() => guardStream(_dataSource.watchLeads());

  @override
  Future<Result<void>> updateStatus({
    required String leadId,
    required LeadStatus status,
  }) {
    return guard(() async {
      await _dataSource.updateStatus(leadId: leadId, statusLabel: status.label);
      await _dataSource.logInteraction(
        leadId: leadId,
        message: 'Status changed to ${status.label}',
      );
    });
  }

  @override
  Future<Result<void>> updatePriority({
    required String leadId,
    required LeadPriority priority,
  }) {
    return guard(() async {
      await _dataSource.updatePriority(
        leadId: leadId,
        priorityLabel: priority.label,
      );
      await _dataSource.logInteraction(
        leadId: leadId,
        message: 'Priority changed to ${priority.label}',
      );
    });
  }

  @override
  Future<Result<void>> addNote({required String leadId, required String note}) {
    return guard(() => _dataSource.addNote(leadId: leadId, note: note));
  }

  @override
  Future<Result<List<LeadNote>>> getNotes(String leadId) =>
      guard(() => _dataSource.fetchNotes(leadId));

        @override
  Future<Result<List<Interaction>>> getInteractions(String leadId) =>
      guard(() => _dataSource.fetchInteractions(leadId));
}
