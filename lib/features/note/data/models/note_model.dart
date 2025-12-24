import '../../domain/entities/note.dart';

class NoteModel extends Note {
  NoteModel({
    required super.id,
    required super.noteTypeId,
    required super.flds,
    required super.sfld,
    required super.createdAt,
    required super.updatedAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      noteTypeId: json['noteTypeId'],
      flds: json['flds'],
      sfld: json['sfld'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'noteTypeId': noteTypeId,
      'flds': flds,
      'sfld': sfld,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'noteTypeId': noteTypeId,
      'flds': flds,
      'sfld': sfld,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
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

  factory NoteModel.fromEntity(Note note) {
    return NoteModel(
      id: note.id,
      noteTypeId: note.noteTypeId,
      flds: note.flds,
      sfld: note.sfld,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
  }

  @override
  NoteModel copyWith({
    String? id,
    String? noteTypeId,
    String? flds,
    String? sfld,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      noteTypeId: noteTypeId ?? this.noteTypeId,
      flds: flds ?? this.flds,
      sfld: sfld ?? this.sfld,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
