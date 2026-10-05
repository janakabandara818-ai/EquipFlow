class Equipment {
  const Equipment({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.condition,
    required this.serviceable,
  });

  final String id;
  final String name;
  final String category;
  final String description;
  final String condition;
  final bool serviceable;

  factory Equipment.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return Equipment(
      id: id,
      name: _readText(data, 'name', 'Unnamed equipment'),
      category: _readText(data, 'category', 'Uncategorized'),
      description: _readText(data, 'description', 'No description provided.'),
      condition: _readText(data, 'condition', 'Unknown'),
      serviceable: data['serviceable'] == true,
    );
  }

  static String _readText(
    Map<String, dynamic> data,
    String field,
    String fallback,
  ) {
    final value = data[field];

    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    return fallback;
  }
}
