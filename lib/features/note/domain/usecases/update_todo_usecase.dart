import '../entities/note.dart';
import '../repositories/note_repository.dart';

class UpdateNoteUseCase {
  final NoteRepository repository;

  UpdateNoteUseCase(this.repository);

  Future<void> call(Note note) {
    return repository.updateNote(note);
  }
}
