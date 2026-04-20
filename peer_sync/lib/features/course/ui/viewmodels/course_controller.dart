import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import '../../../course/domain/models/course.dart';
import '../../domain/repositories/i_course_repository.dart';
import '../../../auth/ui/viewmodels/auth_controller.dart';
import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart';

class CourseController extends GetxController {
  final ICourseRepository repository;

  // Controladores inyectados
  final AuthController authController = Get.find();
  final CategoryController categoryController = Get.find();
  final EvaluationController evaluationController = Get.find();

  CourseController({required this.repository});

  /// Estados reactivos
  final isLoading = false.obs;
  final courses = <Course>[].obs;

  /// ==================== MÉTODOS PRINCIPALES ====================

  /// Cargar todos los cursos del usuario actual
  Future<void> loadCoursesByUser() async {
    try {
      isLoading.value = true;
      final response = await repository.getCoursesByUser();
      courses.assignAll(response);

      // Orquestación: avisar a otros controladores
      _loadRelatedDataForCourses(response);
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Cargar un curso específico por ID (si necesitas)
  Future<void> loadCourses() async {
    try {
      isLoading.value = true;
      final response = await repository.getCourses();
      courses.assignAll(response);
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Crear un nuevo curso
  Future<String?> createCourse(String name) async {
    try {
      isLoading.value = true;

      final newCourse = Course(
        id: _generateId(),
        name: name,
        code: _generateCode(),
      );

      final success = await repository.createCourse(newCourse);

      if (success) {
        final email = authController.user?.email ?? '';
        await repository.joinCourse(newCourse.code.toString(), email);

        await loadCoursesByUser(); // Refrescar lista
        _showSuccess("Curso creado correctamente");
        return newCourse.id;
      }
      return null;
    } catch (e) {
      _showError(e);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Unirse a un curso mediante código
  Future<void> joinCourse(String code) async {
    if (code.isEmpty) return;

    try {
      isLoading.value = true;

      final email = authController.user?.email ?? '';
      await repository.joinCourse(code, email);

      if (Get.isDialogOpen == true) Get.back();

      _showSuccess("¡Te has inscrito al curso correctamente!");
      await loadCoursesByUser();
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Actualizar curso
  Future<void> updateCourse(String id, String newName, int newCode) async {
    try {
      isLoading.value = true;

      final updatedCourse = Course(id: id, name: newName, code: newCode);
      final success = await repository.updateCourse(updatedCourse);

      if (success) {
        await loadCoursesByUser();
        _showSuccess("Curso actualizado correctamente");
      }
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// ==================== MÉTODOS AUXILIARES ====================

  /// Orquestación: cargar datos relacionados después de obtener los cursos
  void _loadRelatedDataForCourses(List<Course> coursesList) {
    for (final course in coursesList) {
      // Cargar categorías (preview)
      categoryController.loadCategoriesForCourseCard(course.id);

      // Cargar categorías del estudiante + conteo de actividades
      categoryController.loadCategoriesForCourseCardByStudent(course.id).then((
        _,
      ) {
        final studentCategories = categoryController.getCategoriesPreview(
          course.id,
        );
        for (final category in studentCategories.take(3)) {
          evaluationController.loadActiveActivitiesCount(category.id);
        }
      });
    }
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  int _generateCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return int.parse(timestamp.toString().substring(0, 8));
  }

  int? getCodeById(String courseId) {
    try {
      return courses.firstWhere((c) => c.id == courseId).code;
    } catch (_) {
      return null;
    }
  }

  /// ==================== MENSAJES ====================

  void _showError(dynamic e) {
    Get.snackbar(
      'Error',
      e.toString().replaceAll('Exception: ', ''),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Theme.of(Get.context!).brightness == Brightness.light
          ? Color(0xFFD1B3FF)
          : Color(0xFF3A3260),
      colorText: Theme.of(Get.context!).brightness == Brightness.light
          ? Colors.black
          : Colors.white,
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Éxito',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  @override
  void onInit() {
    super.onInit();
    loadCoursesByUser(); // Carga automática al iniciar
  }
}
