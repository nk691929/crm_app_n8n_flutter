import 'package:crm_app/core/error/failures.dart';
import 'package:crm_app/core/error/result.dart';
import 'package:crm_app/features/leads/domain/entities/lead.dart';
import 'package:crm_app/features/leads/domain/usecases/update_lead_status.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_leads_repository.dart';
import '../../fakes/test_lead.dart';

void main() {
  late FakeLeadsRepository repository;
  late UpdateLeadStatus useCase;

  setUp(() {
    repository = FakeLeadsRepository();
    useCase = UpdateLeadStatus(repository);
  });

  group('forward moves within the active pipeline', () {
    test('New -> Contacted is allowed', () async {
      final lead = buildTestLead(status: LeadStatus.newLead);
      final result = await useCase(lead: lead, newStatus: LeadStatus.contacted);

      expect(result, isA<Success<void>>());
      expect(repository.lastStatus, LeadStatus.contacted);
    });

    test('New -> Qualified is allowed, skipping a stage', () async {
      final lead = buildTestLead(status: LeadStatus.newLead);
      final result = await useCase(lead: lead, newStatus: LeadStatus.qualified);

      expect(result, isA<Success<void>>());
    });
  });

  group('backward moves within the active pipeline are rejected', () {
    test('Qualified -> New is rejected', () async {
      final lead = buildTestLead(status: LeadStatus.qualified);
      final result = await useCase(lead: lead, newStatus: LeadStatus.newLead);

      expect(result, isA<Err<void>>());
      expect((result as Err<void>).failure, isA<ValidationFailure>());
      expect(
        repository.lastUpdatedLeadId,
        isNull,
      ); // repository was never called
    });

    test('Contacted -> New is rejected', () async {
      final lead = buildTestLead(status: LeadStatus.contacted);
      final result = await useCase(lead: lead, newStatus: LeadStatus.newLead);

      expect(result, isA<Err<void>>());
    });
  });

  group('closing an active lead', () {
    test('New -> Won is allowed and clears next_follow_up_at', () async {
      final lead = buildTestLead(status: LeadStatus.newLead);
      final result = await useCase(lead: lead, newStatus: LeadStatus.won);

      expect(result, isA<Success<void>>());
      expect(repository.lastClearNextFollowUp, isTrue);
      expect(repository.lastNextFollowUpAt, isNull);
    });

    test('Contacted -> Lost is allowed', () async {
      final lead = buildTestLead(status: LeadStatus.contacted);
      final result = await useCase(lead: lead, newStatus: LeadStatus.lost);

      expect(result, isA<Success<void>>());
      expect(repository.lastClearNextFollowUp, isTrue);
    });
  });

  group('reopening a closed lead', () {
    test(
      'Won -> Contacted is allowed and resets the follow-up schedule',
      () async {
        final lead = buildTestLead(status: LeadStatus.won);
        final result = await useCase(
          lead: lead,
          newStatus: LeadStatus.contacted,
        );

        expect(result, isA<Success<void>>());
        expect(repository.lastFollowUpCount, 0);
        expect(repository.lastNextFollowUpAt, isNotNull);
        expect(repository.lastClearNextFollowUp, isFalse);
      },
    );

    test('Won -> New is rejected — cannot reopen straight to New', () async {
      final lead = buildTestLead(status: LeadStatus.won);
      final result = await useCase(lead: lead, newStatus: LeadStatus.newLead);

      expect(result, isA<Err<void>>());
    });

    test(
      'Lost -> Won is rejected — closed statuses cannot swap directly',
      () async {
        final lead = buildTestLead(status: LeadStatus.lost);
        final result = await useCase(lead: lead, newStatus: LeadStatus.won);

        expect(result, isA<Err<void>>());
      },
    );
  });

  group('no-op guard', () {
    test('setting the same status is rejected', () async {
      final lead = buildTestLead(status: LeadStatus.contacted);
      final result = await useCase(lead: lead, newStatus: LeadStatus.contacted);

      expect(result, isA<Err<void>>());
      expect((result as Err<void>).failure, isA<ValidationFailure>());
    });
  });

  group('repository failure propagation', () {
    test('a repository failure is returned as-is to the caller', () async {
      repository.updateStatusResult = const Err(ServerFailure());
      final lead = buildTestLead(status: LeadStatus.newLead);

      final result = await useCase(lead: lead, newStatus: LeadStatus.contacted);

      expect(result, isA<Err<void>>());
      expect((result as Err<void>).failure, isA<ServerFailure>());
    });
  });
}
