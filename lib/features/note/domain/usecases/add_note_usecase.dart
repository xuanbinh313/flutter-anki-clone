import '../entities/note.dart';
import '../repositories/note_repository.dart';

class AddNoteUseCase {
  final NoteRepository repository;

  AddNoteUseCase(this.repository);

  Future<void> call(Note note) {
    return repository.addNote(note);
  }
}
