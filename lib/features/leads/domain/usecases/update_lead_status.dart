import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/lead.dart';
import '../repositories/leads_repository.dart';

class UpdateLeadStatus {
  final LeadsRepository _repository;

  UpdateLeadStatus(this._repository);

  static const _activeOrder = {
    LeadStatus.newLead: 0,
    LeadStatus.contacted: 1,
    LeadStatus.qualified: 2,
  };

  static const _terminal = {LeadStatus.won, LeadStatus.lost};
  static const _reopenTargets = {LeadStatus.contacted, LeadStatus.qualified};

  Future<Result<void>> call({required Lead lead, required LeadStatus newStatus}) {
    if (newStatus == lead.status) {
      return Future.value(
        Err(ValidationFailure('${lead.name} is already ${newStatus.label}.')),
      );
    }

    if (!_isAllowed(lead.status, newStatus)) {
      return Future.value(
        Err(ValidationFailure(
          'Cannot move a lead from ${lead.status.label} to ${newStatus.label}.',
        )),
      );
    }

    final isClosing = _terminal.contains(newStatus);
    final isReopening = _terminal.contains(lead.status) && !isClosing;

    return _repository.updateStatus(
      leadId: lead.id,
      status: newStatus,
      clearNextFollowUp: isClosing,
      nextFollowUpAt: isReopening ? DateTime.now().add(const Duration(days: 3)) : null,
      followUpCount: isReopening ? 0 : null,
    );
  }

  bool _isAllowed(LeadStatus from, LeadStatus to) {
    if (_terminal.contains(from)) return _reopenTargets.contains(to);
    if (_terminal.contains(to)) return true; // any active lead can close
    return _activeOrder[to]! >= _activeOrder[from]!; // forward-only within the pipeline
  }
}