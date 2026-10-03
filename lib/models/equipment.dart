class Equipment {
  final String equipmentId;
  final String name;
  final String category;
  final String description;
  final String condition;
  final bool serviceable;

  const Equipment({
    required this.equipmentId,
    required this.name,
    required this.category,
    required this.description,
    required this.condition,
    required this.serviceable,
  });
}
