import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note_model.dart';

abstract class NoteRemoteDataSource {
  Future<List<NoteModel>> getNotes();
  Future<NoteModel> getNoteById(String id);
  Future<void> addNote(NoteModel note);
  Future<void> updateNote(NoteModel note);
  Future<void> deleteNote(String id);
}

class NoteRemoteDataSourceImpl implements NoteRemoteDataSource {
  final SupabaseClient supabaseClient;

  NoteRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<NoteModel>> getNotes() async {
    final response = await supabaseClient
        .from('notes')
        .select()
        .order('created_at');
    return (response as List).map((json) => NoteModel.fromJson(json)).toList();
  }

  @override
  Future<NoteModel> getNoteById(String id) async {
    final response = await supabaseClient
        .from('notes')
        .select('id,note_type_id,sfld,flds,created_at,updated_at')
        .eq('id', id);
    return NoteModel.fromJson(response.first);
  }

  @override
  Future<void> addNote(NoteModel note) async {
    final data = note.toSupabase();
    data['user_id'] = supabaseClient.auth.currentUser!.id;
    await supabaseClient.from('notes').insert(data);
  }

  @override
  Future<void> updateNote(NoteModel note) async {
    await supabaseClient
        .from('notes')
        .update({
          'note_type_id': note.noteTypeId,
          'flds': note.flds,
          'sfld': note.sfld,
          'updated_at': note.updatedAt.toIso8601String(),
        })
        .eq('id', note.id);
  }

  @override
  Future<void> deleteNote(String id) async {
    await supabaseClient.from('notes').delete().eq('id', id);
  }
}
