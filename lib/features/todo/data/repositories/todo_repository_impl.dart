import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_datasource.dart';
import '../datasources/todo_remote_datasource.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource localDataSource;
  final TodoRemoteDataSource remoteDataSource;

  TodoRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  Future<bool> get _isConnected async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  @override
  Future<List<Todo>> getTodos() async {
    if (await _isConnected) {
      try {
        final remoteTodos = await remoteDataSource.getTodos();
        await localDataSource.cacheTodos(remoteTodos);
        return remoteTodos;
      } catch (e) {
        // Fallback to local if remote fails
        return await _getLocalTodos();
      }
    } else {
      return await _getLocalTodos();
    }
  }

  Future<List<Todo>> _getLocalTodos() async {
    return await localDataSource.getTodos();
  }

  @override
  Future<void> addTodo(Todo todo) async {
    final todoModel = TodoModel.fromEntity(todo);
    await localDataSource.cacheTodo(
      todoModel.copyWith(synced: false),
    ); // Mark unsynced initially

    if (await _isConnected) {
      try {
        await remoteDataSource.addTodo(todoModel);
        await localDataSource.updateTodo(todoModel.copyWith(synced: true));
      } catch (e) {
        // failed to sync, keep as unsynced
      }
    }
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    final todoModel = TodoModel.fromEntity(todo);
    await localDataSource.updateTodo(todoModel.copyWith(synced: false));

    if (await _isConnected) {
      try {
        await remoteDataSource.updateTodo(todoModel);
        await localDataSource.updateTodo(todoModel.copyWith(synced: true));
      } catch (e) {
        // failed to sync
      }
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    await localDataSource.deleteTodo(id);

    if (await _isConnected) {
      try {
        await remoteDataSource.deleteTodo(id);
      } catch (e) {
        // If offline delete fails, we might need a "deleted_at" soft delete logic to sync later,
        // but for this sample, we'll assume we just delete locally.
        // Real world would need soft-deletes or a "pending_deletions" table.
      }
    }
  }

  @override
  Future<void> syncTodos() async {
    // This would be called periodically or on app start to push unsynced changes
    // For now, leaving empty or simple implementation.
    // We would query local todos where synced = false and try to push them.
    if (await _isConnected) {
      final localTodos = await localDataSource.getTodos();
      final unsynced = localTodos.where((t) => !t.synced).toList();
      for (var todo in unsynced) {
        // Determine if it's new, or update?
        // Simplified: Try Upsert if supported or just add (might dupe if partial state).
        // For this sample, let's assume valid ID means we can try update/add.
        try {
          await remoteDataSource.addTodo(
            todo,
          ); // Assuming add handles upsert or we check id first
          await localDataSource.updateTodo(todo.copyWith(synced: true));
        } catch (e) {
          // try update if add failed?
          try {
            await remoteDataSource.updateTodo(todo);
            await localDataSource.updateTodo(todo.copyWith(synced: true));
          } catch (e2) {}
        }
      }
    }
  }
}
