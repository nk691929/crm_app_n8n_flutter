import 'package:crm_app/features/leads/domain/entities/lead.dart';
import 'package:crm_app/features/leads/presentation/providers/leads_providers.dart';
import 'package:crm_app/features/leads/presentation/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/test_lead.dart';

void main() {
  testWidgets('shows a loading indicator while leads are loading', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          leadsStreamProvider.overrideWith((ref) => const Stream.empty()),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('does not throw when leads load successfully', (tester) async {
    final leads = [buildTestLead(id: '1', name: 'Alice')];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          leadsStreamProvider.overrideWith((ref) => Stream.value(leads)),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('shows an error message and retry button when loading fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          leadsStreamProvider.overrideWith(
            (ref) => Stream<List<Lead>>.error(Exception('network down')),
          ),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Unable to load leads'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Try Again'), findsOneWidget);
  });
}
