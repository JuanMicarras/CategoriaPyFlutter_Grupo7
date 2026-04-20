// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/features/course/ui/widgets/course_card.dart';
import '../../domain/models/category.dart';
import '../../domain/repositories/i_category_repository.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';

class CategoryController extends GetxController {
  final ICategoryRepository repository;

  CategoryController({required this.repository});

  final categories = <Category>[].obs;
  final categoriesByCourse = <String, List<Category>>{}.obs;
  final isLoading = false.obs;

  Future<void> loadCategories(String courseId) async {
    print('el id del curso es: $courseId');
    try {
      print("🔥 Cargando categorías para curso: $courseId");

      isLoading.value = true;

      final response = await repository.getCategoriesByCourse(courseId);

      print("📦 Categorías recibidas: $response");

      categories.assignAll(response);
    } catch (e) {
      print("❌ ERROR: $e");
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCategoriesForCourseCard(String courseId) async {
    try {
      /// 🚫 Evitar llamadas repetidas
      if (categoriesByCourse.containsKey(courseId)) return;

      final response = await repository.getCategoriesByCourse(courseId);

      categoriesByCourse[courseId] = response;
    } catch (e) {
      print("❌ Error cargando categorías para curso $courseId: $e");
    }
  }

  Future<void> loadCategoriesByStudent(String courseId) async {
    try {
      print("🎓 Cargando categorías SOLO del estudiante");
      isLoading.value = true;

      final response = await repository.getCategoriesByStudent(courseId);
      print("📦 Categorías filtradas: $response");
      categories.assignAll(response);
      // Apenas llegan las categorías, mandamos a buscar el conteo de actividades
      if (Get.isRegistered<EvaluationController>()) {
        final evalCtrl = Get.find<EvaluationController>();
        for (var category in response) {
          evalCtrl.loadActiveActivitiesCount(category.id);
        }
      }
    } catch (e) {
      print("❌ ERROR: $e");
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCategoriesForCourseCardByStudent(String courseId) async {
    try {
      /// 🚫 evitar repetir llamadas
      if (categoriesByCourse.containsKey(courseId)) return;

      final response = await repository.getCategoriesByStudent(courseId);

      categoriesByCourse[courseId] = response;
    } catch (e) {
      print("❌ Error cargando preview estudiante: $e");
    }
  }

  /// 🔥 NUEVO: OBTENER PREVIEW
  List<Category> getCategoriesPreview(String courseId) {
    return categoriesByCourse[courseId] ?? [];
  }

  List<CourseProjectItem> getCourseProjectItems(String courseId) {
    final categoriesList = categoriesByCourse[courseId] ?? [];

    // Aquí hacemos la lógica de negocio de la UI: Tomar 3 y formatear.
    return categoriesList
        .take(3)
        .map((c) => CourseProjectItem(title: c.name, subtitle: "Grupo"))
        .toList();
  }

  void _showError(dynamic e) {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
            style: TextStyle(
              color: Theme.of(Get.context!).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
            ),
          ),
          backgroundColor: Theme.of(Get.context!).brightness == Brightness.light
              ? Color(0xFFD1B3FF)
              : Color(0xFF3A3260),
        ),
      );
    }
  }

  String getCategoryCountText(String courseId) {
    final count = (categoriesByCourse[courseId] ?? []).length;
    if (count == 0) return "Sin categorías";
    if (count == 1) return "1 categoría";
    return "$count categorías";
  }
}
