import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/course.dart';
import '../../domain/repositories/i_course_repository.dart';

class CourseController extends GetxController {
  final ICourseRepository repository;

  int _generateCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return int.parse(timestamp.toString().substring(0, 8));
  }

  CourseController({required this.repository});

  /// 🔥 ESTADOS REACTIVOS
  final isLoading = false.obs;
  final courses = <Course>[].obs;

  /// 🔥 OBTENER CURSOS DESDE BACKEND
  Future<void> loadCourses() async {
    try {
      isLoading.value = true;

      final response = await repository.getCourses();

      courses.assignAll(response); // 🔥 reactivo
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

      final updatedCourse = Course(id: id, name: newName, code: newCode);

      final success = await repository.updateCourse(updatedCourse);

      if (success) {
        await loadCourses();
      }
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔥 GENERAR ID (13 dígitos aprox)
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// 🔥 MANEJO DE ERRORES (igual que Auth)
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

  @override
  void onInit() {
    super.onInit();
    loadCourses(); // 🔥 carga automática al entrar
  }
}
