import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../course/domain/models/course.dart';
import '../../domain/repositories/i_course_repository.dart';
import '../../../auth/ui/viewmodels/auth_controller.dart';

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
  Future<void> createCourse(String name) async {
    try {
      isLoading.value = true;

      final course = Course(
        id: _generateId(),
        name: name,
        code: _generateCode(),
      );

      final success = await repository.createCourse(course);

      if (success) {
        await loadCourses();

        _showSuccess("Curso creado correctamente");
      }
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔥 ACTUALIZAR CURSO
  Future<void> updateCourse(String id, String newName, int newCode) async {
    try {
      isLoading.value = true;

      final updatedCourse = Course(
        id: id,
        name: newName,
        code: newCode,
      );

      final success = await repository.updateCourse(updatedCourse);

      if (success) {
        await loadCourses();

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

      await loadCourses(); // 🔥 refresca lista
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
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
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadCourses(); // 🔥 carga automática
  }
}
