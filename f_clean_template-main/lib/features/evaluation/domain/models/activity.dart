class Activity {
  final String id;
  final String categoryId;
  final String name;
  final String? description; // Puede ser null
  final DateTime startDate;
  final DateTime endDate;
  final bool visibility;

  Activity({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.visibility,
  });
}