class Template {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  Template({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  Template copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Template(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
