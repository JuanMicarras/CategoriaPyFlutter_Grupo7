import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../domain/repositories/i_evaluation_repository.dart';
import '../../domain/models/activity_report.dart';

class TeacherReportController extends GetxController {
  final IEvaluationRepository repository;

  final isLoading = false.obs;
  final groupReports = <GroupReport>[].obs;

  TeacherReportController(this.repository);

  Future<void> loadReport(String activityId, String categoryId) async {
    try {
      isLoading.value = true;
      final result = await repository.getActivityReport(activityId, categoryId);
      groupReports.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cargar el reporte: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String formatStudentName(String firstName, String lastName) {
    // Si más adelante quieres aplicar TitleCase a todos los estudiantes,
    // lo haces aquí y se arregla en toda la app sin tocar la UI.
    return "$firstName $lastName";
  }

  // 2. Formatear la nota
  String formatGrade(double grade) {
    return grade.toStringAsFixed(1);
  }

  // 3. Obtener el texto y colores del estado (Usando Records de Dart)
  ({String text, Color bgColor, Color textColor}) getStudentStatusUI(
    bool isComplete,
  ) {
    final isLight = Theme.of(Get.context!).brightness == Brightness.light;

    if (isComplete) {
      return (
        text: "Evaluaciones completas",
        bgColor: Theme.of(Get.context!).brightness == Brightness.light
            ? Color(0xFFD1B3FF)
            : Color(0xFF3A3260),
        textColor: Theme.of(Get.context!).brightness == Brightness.light
            ? Colors.black
            : Colors.white,
      );
    } else {
      return (
        text: "Falta por evaluar",
        bgColor: isLight ? Color(0xFFD1B3FF) : Color(0xFF3A3260),
        textColor: isLight ? Colors.black : Colors.white,
      );
    }
  }
}
