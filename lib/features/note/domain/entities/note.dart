class Note {
  final String id;
  final String noteTypeId;
  final List<String> fields;
  final String sfld;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.noteTypeId,
    required this.fields,
    required this.sfld,
    required this.createdAt,
    required this.updatedAt,
  });

  Note copyWith({
    String? id,
    String? noteTypeId,
    List<String>? fields,
    String? sfld,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      noteTypeId: noteTypeId ?? this.noteTypeId,
      fields: fields ?? this.fields,
      sfld: sfld ?? this.sfld,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
