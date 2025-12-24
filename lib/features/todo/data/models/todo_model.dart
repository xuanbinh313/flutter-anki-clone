import '../../domain/entities/todo.dart';

class TodoModel extends Todo {
  TodoModel({
    required super.id,
    required super.title,
    super.isCompleted,
    required super.createdAt,
    super.synced,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],
      title: json['title'],
      isCompleted: json['is_completed'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      synced:
          json['synced'] == 1 ||
          json['synced'] == true, // Handle SQLite (0/1) and Supabase (bool)
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'title': title,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'title': title,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
      'user_id':
          _getUserId(), // Assuming user_id is handled by RLS or manually injected if needed.
      // Actually it's better to inject user_id from repository or let Supabase Auth handle it via defaults/triggers if possible.
      // But typically we send it or let the backend infer.
      // For now, let's assume we might need it, but since this model doesn't hold user_id, we will rely on Supabase Auth context or add it in Repository.
    };
  }

  // Placeholder for user_id logic if needed, but for now we'll keep toSupabase simple
  // and handle user injection in the Datasource/Repository.

  static String? _getUserId() {
    // This is a bit dirty to access global state here, better to pass it in.
    return null;
  }

  factory TodoModel.fromEntity(Todo todo) {
    return TodoModel(
      id: todo.id,
      title: todo.title,
      isCompleted: todo.isCompleted,
      createdAt: todo.createdAt,
      synced: todo.synced,
    );
  }

  @override
  TodoModel copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    bool? synced,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
    );
  }
}
