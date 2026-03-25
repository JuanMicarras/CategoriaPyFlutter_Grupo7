import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../domain/repositories/i_course_repository.dart';
import '../../../auth/ui/viewmodels/auth_controller.dart';

class CourseController extends GetxController {
  final ICourseRepository repository;
  
  // Inyectamos el AuthController para saber quién es el usuario actual
  final AuthController authController = Get.find(); 

  final isLoading = false.obs;

  CourseController(this.repository);

  Future<void> joinCourse(String code) async {
    if (code.isEmpty) return;

    try {
      isLoading.value = true;
      final email = authController.user?.email ?? '';
      
      // 1. Llamamos a la API
      await repository.joinCourse(code, email);
      
      // 2. Si todo sale bien, cerramos el modal con GetX
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      // 3. Mostramos mensaje de éxito seguro (ScaffoldMessenger)
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(
            content: Text('¡Te has inscrito al curso correctamente!'),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {
      // Si hay error, NO cerramos el modal, solo mostramos el mensaje rojo
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}

