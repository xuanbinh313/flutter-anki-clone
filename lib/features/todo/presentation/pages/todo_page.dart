import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/todo_viewmodel.dart';

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoState = ref.watch(todoListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Todo List')),
      body: todoState.when(
        data: (todos) {
          if (todos.isEmpty) {
            return const Center(child: Text('No todos yet.'));
          }
          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return ListTile(
                leading: Checkbox(
                  value: todo.isCompleted,
                  onChanged: (_) {
                    ref.read(todoListProvider.notifier).toggleTodo(todo);
                  },
                ),
                title: Text(
                  todo.title,
                  style: TextStyle(
                    decoration: todo.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    ref.read(todoListProvider.notifier).deleteTodo(todo.id);
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddTodoDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Todo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Todo title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(todoListProvider.notifier).addTodo(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
