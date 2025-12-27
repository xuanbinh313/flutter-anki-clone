import 'package:anki_clone/utils/parse.dart';

import '../../domain/entities/template.dart';

class TemplateModel extends Template {
  TemplateModel({
    required super.id,
    required super.name,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.microsecondsSinceEpoch ~/ 1000,
      'updated_at': updatedAt.microsecondsSinceEpoch ~/ 1000,
    };
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'name': name,
      'created_at': toIsoWithOffset(createdAt),
      'updated_at': toIsoWithOffset(updatedAt),
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

  factory TemplateModel.fromEntity(Template template) {
    return TemplateModel(
      id: template.id,
      name: template.name,
      createdAt: template.createdAt,
      updatedAt: template.updatedAt,
    );
  }

  @override
  TemplateModel copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TemplateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
