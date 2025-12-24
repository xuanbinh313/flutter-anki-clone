class Todo {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;
  final bool synced;

  Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
    this.synced = false,
  });

  Todo copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    bool? synced,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
    );
  }
}
