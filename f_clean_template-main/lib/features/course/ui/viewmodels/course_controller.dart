import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import '../../../course/domain/models/course.dart';
import '../../domain/repositories/i_course_repository.dart';
import '../../../auth/ui/viewmodels/auth_controller.dart';
import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart'; 

class CourseController extends GetxController {
  final ICourseRepository repository;

  // 🔥 Inyectamos AuthController
  final AuthController authController = Get.find();

  CourseController({required this.repository});

  /// 🔥 ESTADOS REACTIVOS
  final isLoading = false.obs;
  final courses = <Course>[].obs;

  /// 🔥 GENERAR CODE (8 dígitos aprox)
  int _generateCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return int.parse(timestamp.toString().substring(0, 8));
  }

  /// 🔥 GENERAR ID
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// 🔥 OBTENER CURSOS
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

  /// 🔥 CREAR CURSO
  Future<String?> createCourse(String name) async {
    try {
      isLoading.value = true;
      final newCourseId = _generateId();

      final course = Course(
        id: newCourseId,
        name: name,
        code: _generateCode(),
      );

      final success = await repository.createCourse(course);

      if (success) {
        final email = authController.user?.email ?? '';

        // 🔥 ESTA LÍNEA TE FALTA
        await repository.joinCourse(course.code.toString(), email);

        await loadCoursesByUser();

        _showSuccess("Curso creado correctamente");
        return newCourseId;
      }
      return null;
    } catch (e) {
      _showError(e);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔥 ACTUALIZAR CURSO
  Future<void> updateCourse(String id, String newName, int newCode) async {
    try {
      isLoading.value = true;

      final updatedCourse = Course(id: id, name: newName, code: newCode);

      final success = await repository.updateCourse(updatedCourse);

      if (success) {
        await loadCoursesByUser();

        _showSuccess("Curso actualizado");
      }
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔥 UNIRSE A CURSO (ANTES estaba en el otro controller)
  Future<void> joinCourse(String code) async {
    if (code.isEmpty) return;

    try {
      isLoading.value = true;

      final email = authController.user?.email ?? '';

      await repository.joinCourse(code, email);

      if (Get.isDialogOpen == true) {
        Get.back();
      }

      _showSuccess("¡Te has inscrito al curso correctamente!");

      await loadCoursesByUser(); // 🔥 refresca lista
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCoursesByUser() async {
    try {
      isLoading.value = true;
      final response = await repository.getCoursesByUser();
      courses.assignAll(response);

      // 🔥 LA MAGIA DE LA ORQUESTACIÓN
      // El CourseController le avisa a los demás que hagan su trabajo
      if (Get.isRegistered<CategoryController>()) {
        final categoryCtrl = Get.find<CategoryController>();
        // Buscamos si el controlador de evaluación está en memoria
        final evalCtrl = Get.isRegistered<EvaluationController>() ? Get.find<EvaluationController>() : null;

        for (var course in response) {
          // 1. Cargamos el preview del profesor
          categoryCtrl.loadCategoriesForCourseCard(course.id);
          
          // 2. Cargamos el preview del estudiante y ENCADENAMOS la carga de evaluaciones
          categoryCtrl.loadCategoriesForCourseCardByStudent(course.id).then((_) {
            // Cuando las categorías del estudiante llegan, mandamos a contar las actividades
            final studentCategories = categoryCtrl.getCategoriesPreview(course.id);
            for (var category in studentCategories.take(3)) {
              evalCtrl?.loadActiveActivitiesCount(category.id);
            }
          });
        }
      }
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  int? getCodeById(String courseId) {
    try {
      final course = courses.firstWhere((c) => c.id == courseId);
      return course.code;
    } catch (e) {
      return null;
    }
  }

  /// 🔥 MENSAJES
  void _showError(dynamic e) {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showSuccess(String message) {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadCoursesByUser(); // 🔥 carga automática
  }
}
