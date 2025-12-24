class Note {
  final String id;
  final String noteTypeId;
  final String flds;
  final String sfld;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.noteTypeId,
    required this.flds,
    required this.sfld,
    required this.createdAt,
    required this.updatedAt,
  });

  Note copyWith({
    String? id,
    String? noteTypeId,
    String? flds,
    String? sfld,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      noteTypeId: noteTypeId ?? this.noteTypeId,
      flds: flds ?? this.flds,
      sfld: sfld ?? this.sfld,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
