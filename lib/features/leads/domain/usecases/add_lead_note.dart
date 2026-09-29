import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../repositories/leads_repository.dart';

class AddLeadNote {
  final LeadsRepository _repository;

  AddLeadNote(this._repository);

  static const _maxLength = 1000;

  Future<Result<void>> call({required String leadId, required String note}) {
    final trimmed = note.trim();

    if (trimmed.isEmpty) {
      return Future.value(
        const Err(ValidationFailure('Note cannot be empty.')),
      );
    }
    if (trimmed.length > _maxLength) {
      return Future.value(
        Err(
          ValidationFailure('Note is too long (max $_maxLength characters).'),
        ),
      );
    }

    return _repository.addNote(leadId: leadId, note: trimmed);
  }
}
