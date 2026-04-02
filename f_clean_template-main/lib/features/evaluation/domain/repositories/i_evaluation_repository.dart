import '../models/activity.dart';

abstract class IEvaluationRepository {
  // Recibimos los datos básicos para crear la actividad
  Future<void> createActivity({
    required String categoryId,
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required bool visibility,
  });
}