import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../main.dart'; // Accessing global supabase client
import '../../domain/entities/todo.dart';
import '../../domain/usecases/add_todo_usecase.dart';
import '../../domain/usecases/delete_todo_usecase.dart';
import '../../domain/usecases/get_todos_usecase.dart';
import '../../domain/usecases/update_todo_usecase.dart';
import '../../data/datasources/todo_local_datasource.dart';
import '../../data/datasources/todo_remote_datasource.dart';
import '../../data/repositories/todo_repository_impl.dart';

// Data Sources
final todoLocalDataSourceProvider = Provider<TodoLocalDataSource>((ref) {
  return TodoLocalDataSourceImpl();
});

final todoRemoteDataSourceProvider = Provider<TodoRemoteDataSource>((ref) {
  return TodoRemoteDataSourceImpl(supabaseClient: supabase);
});

// Repository
final todoRepositoryProvider = Provider<TodoRepositoryImpl>((ref) {
  return TodoRepositoryImpl(
    localDataSource: ref.watch(todoLocalDataSourceProvider),
    remoteDataSource: ref.watch(todoRemoteDataSourceProvider),
  );
});

// Use Cases
final getTodosUseCaseProvider = Provider(
  (ref) => GetTodosUseCase(ref.watch(todoRepositoryProvider)),
);
final addTodoUseCaseProvider = Provider(
  (ref) => AddTodoUseCase(ref.watch(todoRepositoryProvider)),
);
final updateTodoUseCaseProvider = Provider(
  (ref) => UpdateTodoUseCase(ref.watch(todoRepositoryProvider)),
);
final deleteTodoUseCaseProvider = Provider(
  (ref) => DeleteTodoUseCase(ref.watch(todoRepositoryProvider)),
);

// ViewModel (AsyncNotifier)
class TodoListNotifier extends AsyncNotifier<List<Todo>> {
  @override
  FutureOr<List<Todo>> build() async {
    return _getTodos();
  }

  Future<List<Todo>> _getTodos() {
    final getTodos = ref.read(getTodosUseCaseProvider);
    return getTodos();
  }

  Future<void> addTodo(String title) async {
    final addTodo = ref.read(addTodoUseCaseProvider);
    final newTodo = Todo(
      id: const Uuid().v4(),
      title: title,
      createdAt: DateTime.now(),
      isCompleted: false,
    );

    final previousState = state;
    if (state.hasValue) {
      state = AsyncValue.data([...state.value!, newTodo]);
    }

    try {
      await addTodo(newTodo);
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> toggleTodo(Todo todo) async {
    final updateTodo = ref.read(updateTodoUseCaseProvider);
    final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);

    final previousState = state;
    if (state.hasValue) {
      state = AsyncValue.data([
        for (final t in state.value!)
          if (t.id == todo.id) updatedTodo else t,
      ]);
    }

    try {
      await updateTodo(updatedTodo);
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> deleteTodo(String id) async {
    final deleteTodo = ref.read(deleteTodoUseCaseProvider);
    // Optimistic update
    final previousState = state;
    if (state.hasValue) {
      state = AsyncValue.data([
        for (final t in state.value!)
          if (t.id != id) t,
      ]);
    }

    try {
      await deleteTodo(id);
    } catch (e) {
      state = previousState;
    }
  }
}

final todoListProvider = AsyncNotifierProvider<TodoListNotifier, List<Todo>>(
  () {
    return TodoListNotifier();
  },
);
