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

  Future<void> updateStatus({required String leadId, required String statusLabel}) async {
    await _client.from('leads').update({'status': statusLabel}).eq('id', leadId);
  }

  Future<void> updatePriority({required String leadId, required String priorityLabel}) async {
    await _client.from('leads').update({'priority': priorityLabel}).eq('id', leadId);
  }

  Future<void> addNote({required String leadId, required String note}) async {
    await _client.from('notes').insert({'lead_id': leadId, 'note': note});
  }
}