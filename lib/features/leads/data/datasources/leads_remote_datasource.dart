import 'package:crm_app/core/error/exceptions.dart';
import 'package:crm_app/features/leads/data/models/lead_note_model.dart';
import 'package:crm_app/features/leads/domain/entities/lead_note.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/lead_model.dart';
import '../../domain/entities/lead.dart';

class LeadsRemoteDataSource {
  final SupabaseClient _client;

  LeadsRemoteDataSource(this._client);

  Stream<List<Lead>> watchLeads() {
    return _client
        .from('leads')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) => rows.map(LeadModel.fromJson).toList());
  }

  Future<void> updateStatus({
    required String leadId,
    required String statusLabel,
  }) async {
    final rows = await _client
        .from('leads')
        .update({'status': statusLabel})
        .eq('id', leadId)
        .select('id');
    if (rows.isEmpty) throw const NoRowsAffectedException();
  }

  Future<void> updatePriority({
    required String leadId,
    required String priorityLabel,
  }) async {
    final rows = await _client
        .from('leads')
        .update({'priority': priorityLabel})
        .eq('id', leadId)
        .select('id');
    if (rows.isEmpty) throw const NoRowsAffectedException();
  }

  Future<void> addNote({required String leadId, required String note}) async {
    await _client.from('notes').insert({'lead_id': leadId, 'note': note});
  }

   Future<List<LeadNote>> fetchNotes(String leadId) async {
    final rows = await _client
        .from('notes')
        .select()
        .eq('lead_id', leadId)
        .order('created_at', ascending: false);
    return rows.map(LeadNoteModel.fromJson).toList();
  }
}
