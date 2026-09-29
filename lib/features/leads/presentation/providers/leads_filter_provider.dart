import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/lead.dart';

class LeadsFilter {
  final String query;
  final LeadPriority? priority;

  const LeadsFilter({this.query = '', this.priority});

  LeadsFilter copyWith({String? query, LeadPriority? priority, bool clearPriority = false}) {
    return LeadsFilter(
      query: query ?? this.query,
      priority: clearPriority ? null : (priority ?? this.priority),
    );
  }
}

class LeadsFilterNotifier extends Notifier<LeadsFilter> {
  @override
  LeadsFilter build() => const LeadsFilter();

  void setQuery(String query) => state = state.copyWith(query: query);

  void setPriority(LeadPriority? priority) {
    state = priority == null
        ? state.copyWith(clearPriority: true)
        : state.copyWith(priority: priority);
  }
}

final leadsFilterProvider = NotifierProvider<LeadsFilterNotifier, LeadsFilter>(
  LeadsFilterNotifier.new,
);

List<Lead> applyLeadsFilter(List<Lead> leads, LeadsFilter filter) {
  final query = filter.query.trim().toLowerCase();

  return leads.where((lead) {
    final matchesQuery = query.isEmpty ||
        lead.name.toLowerCase().contains(query) ||
        lead.phone.toLowerCase().contains(query) ||
        (lead.email?.toLowerCase().contains(query) ?? false);

    final matchesPriority = filter.priority == null || lead.priority == filter.priority;

    return matchesQuery && matchesPriority;
  }).toList();
}