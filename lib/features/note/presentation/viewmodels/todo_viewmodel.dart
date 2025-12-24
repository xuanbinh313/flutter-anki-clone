import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../main.dart'; // Accessing global supabase client
import '../../domain/entities/note.dart';
import '../../domain/usecases/add_todo_usecase.dart';
import '../../domain/usecases/delete_todo_usecase.dart';
import '../../domain/usecases/get_todos_usecase.dart';
import '../../domain/usecases/update_todo_usecase.dart';
import '../../data/datasources/note_remote_datasource.dart';
import '../../data/repositories/note_repository_impl.dart';

// Data Sources
final noteRemoteDataSourceProvider = Provider<NoteRemoteDataSource>((ref) {
  return NoteRemoteDataSourceImpl(supabaseClient: supabase);
});

// Repository
final noteRepositoryProvider = Provider<NoteRepositoryImpl>((ref) {
  return NoteRepositoryImpl(
    remoteDataSource: ref.watch(noteRemoteDataSourceProvider),
  );
});

// Use Cases
final getNotesUseCaseProvider = Provider(
  (ref) => GetNotesUseCase(ref.watch(noteRepositoryProvider)),
);
final addNoteUseCaseProvider = Provider(
  (ref) => AddNoteUseCase(ref.watch(noteRepositoryProvider)),
);
final updateNoteUseCaseProvider = Provider(
  (ref) => UpdateNoteUseCase(ref.watch(noteRepositoryProvider)),
);
final deleteNoteUseCaseProvider = Provider(
  (ref) => DeleteNoteUseCase(ref.watch(noteRepositoryProvider)),
);

// ViewModel (AsyncNotifier)
class NoteListNotifier extends AsyncNotifier<List<Note>> {
  @override
  FutureOr<List<Note>> build() async {
    return _getNotes();
  }

  Future<List<Note>> _getNotes() {
    final getNotes = ref.read(getNotesUseCaseProvider);
    return getNotes();
  }

  Future<void> addNote(Note note) async {
    final addNote = ref.read(addNoteUseCaseProvider);
    final newNote = Note(
      id: const Uuid().v4(),
      noteTypeId: "",
      flds: "",
      sfld: "",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final previousState = state;
    if (state.hasValue) {
      state = AsyncValue.data([...state.value!, newNote]);
    }

    try {
      await addNote(newNote);
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> updateNote(Note note) async {
    final updateNote = ref.read(updateNoteUseCaseProvider);
    final updatedNote = note.copyWith(updatedAt: DateTime.now());

    final previousState = state;
    if (state.hasValue) {
      state = AsyncValue.data([
        for (final t in state.value!)
          if (t.id == note.id) updatedNote else t,
      ]);
    }

    try {
      await updateNote(updatedNote);
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> deleteNote(String id) async {
    final deleteNote = ref.read(deleteNoteUseCaseProvider);
    // Optimistic update
    final previousState = state;
    if (state.hasValue) {
      state = AsyncValue.data([
        for (final t in state.value!)
          if (t.id != id) t,
      ]);
    }

    try {
      await deleteNote(id);
    } catch (e) {
      state = previousState;
    }
  }
}

final noteListProvider = AsyncNotifierProvider<NoteListNotifier, List<Note>>(
  () {
    return NoteListNotifier();
  },
);
