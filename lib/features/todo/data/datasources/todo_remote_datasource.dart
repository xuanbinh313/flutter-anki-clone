import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/todo_model.dart';

abstract class TodoRemoteDataSource {
  Future<List<TodoModel>> getTodos();
  Future<void> addTodo(TodoModel todo);
  Future<void> updateTodo(TodoModel todo);
  Future<void> deleteTodo(String id);
}

class TodoRemoteDataSourceImpl implements TodoRemoteDataSource {
  final SupabaseClient supabaseClient;

  TodoRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<TodoModel>> getTodos() async {
    final response = await supabaseClient
        .from('todos')
        .select()
        .order('created_at');
    return (response as List).map((json) => TodoModel.fromJson(json)).toList();
  }

  @override
  Future<void> addTodo(TodoModel todo) async {
    final data = todo.toSupabase();
    data['user_id'] = supabaseClient.auth.currentUser!.id; // Inject user_id
    await supabaseClient.from('todos').insert(data);
  }

  @override
  Future<void> updateTodo(TodoModel todo) async {
    await supabaseClient
        .from('todos')
        .update({
          'title': todo.title,
          'is_completed': todo.isCompleted,
          // 'created_at': todo.createdAt.toIso8601String(), // Ensure created_at is not changed usually, but fine if strictly defined
        })
        .eq('id', todo.id);
  }

  @override
  Future<void> deleteTodo(String id) async {
    await supabaseClient.from('todos').delete().eq('id', id);
  }
}
