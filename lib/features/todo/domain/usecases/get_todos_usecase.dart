import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

class GetTodosUseCase {
  final TodoRepository repository;

  GetTodosUseCase(this.repository);

  Future<List<Todo>> call() {
    return repository.getTodos();
  }
}
