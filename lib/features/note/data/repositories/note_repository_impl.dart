import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/note_remote_datasource.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteRemoteDataSource remoteDataSource;

  NoteRepositoryImpl({required this.remoteDataSource});

  Future<bool> get _isConnected async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  @override
  Future<List<Note>> getNotes() async {
    final remoteNotes = await remoteDataSource.getNotes();
    return remoteNotes;
  }

  @override
  Future<Note> getNoteById(String id) async {
    final remoteNote = await remoteDataSource.getNoteById(id);
    return remoteNote;
  }

  @override
  Future<void> addNote(Note note) async {
    final noteModel = NoteModel.fromEntity(note);

    if (await _isConnected) {
      try {
        await remoteDataSource.addNote(noteModel);
      } catch (e) {
        // failed to sync, keep as unsynced
      }
    }
  }

  @override
  Future<void> updateNote(Note note) async {
    final noteModel = NoteModel.fromEntity(note);

    if (await _isConnected) {
      try {
        await remoteDataSource.updateNote(noteModel);
      } catch (e) {
        // failed to sync
      }
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    await remoteDataSource.deleteNote(id);
  }

  Future<void> syncNotes() async {
    // This would be called periodically or on app start to push unsynced changes
    // For now, leaving empty or simple implementation.
    // We would query local todos where synced = false and try to push them.
    if (await _isConnected) {
      final remoteNotes = await remoteDataSource.getNotes();
      for (var note in remoteNotes) {
        try {
          await remoteDataSource.addNote(
            note,
          ); // Assuming add handles upsert or we check id first
        } catch (e) {
          try {
            await remoteDataSource.updateNote(note);
          } catch (e2) {
            // failed to sync
          }
        }
      }
    }
  }
}
