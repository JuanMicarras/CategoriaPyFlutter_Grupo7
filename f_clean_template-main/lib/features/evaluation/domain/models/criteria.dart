class Criteria {
  final String id;
  final String activityId;
  final String name;
  final String? description;
  final double maxScore; // double para manejar los decimales de 5.0

  Criteria({
    required this.id,
    required this.activityId,
    required this.name,
    this.description,
    required this.maxScore,
  });
}