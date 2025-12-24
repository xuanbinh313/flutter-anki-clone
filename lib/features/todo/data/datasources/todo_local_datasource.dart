import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:anki_clone/features/todo/data/models/todo_model.dart';

abstract class TodoLocalDataSource {
  Future<List<TodoModel>> getTodos();
  Future<void> cacheTodo(TodoModel todo);
  Future<void> cacheTodos(List<TodoModel> todos);
  Future<void> deleteTodo(String id);
  Future<void> updateTodo(TodoModel todo);
}

class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('todos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        is_completed INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        synced INTEGER NOT NULL
      )
    ''');
  }

  @override
  Future<List<TodoModel>> getTodos() async {
    final db = await database;
    final result = await db.query('todos', orderBy: 'created_at DESC');
    return result.map((json) => TodoModel.fromJson(json)).toList();
  }

  @override
  Future<void> cacheTodo(TodoModel todo) async {
    final db = await database;
    await db.insert(
      'todos',
      todo.toSqlite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> cacheTodos(List<TodoModel> todos) async {
    final db = await database;
    final batch = db.batch();
    for (var todo in todos) {
      batch.insert(
        'todos',
        todo.toSqlite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> deleteTodo(String id) async {
    final db = await database;
    await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> updateTodo(TodoModel todo) async {
    final db = await database;
    await db.update(
      'todos',
      todo.toSqlite(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }
}
