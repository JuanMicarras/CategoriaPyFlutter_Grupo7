// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/category.dart';
import '../../domain/repositories/i_category_repository.dart';

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

  void _showError(dynamic e) {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
