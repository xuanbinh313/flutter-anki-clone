import '../entities/note.dart';
import '../repositories/note_repository.dart';

class GetNoteByIdUseCase {
  final NoteRepository repository;

  GetNoteByIdUseCase(this.repository);

  Future<Note> call(String id) {
    return repository.getNoteById(id);
  }
}
