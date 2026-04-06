import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/repositories/i_groups_repository.dart';
import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart'; 

class GroupsController extends GetxController {
  final IGroupsRepository repository;
  final isLoading = false.obs;

  GroupsController(this.repository);

  // courseId es el ID del curso al que el profesor le está subiendo los grupos
  Future<void> pickAndImportCsv(String courseId) async {
    try {
      // 1. Abrir el selector de archivos
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true, // Importante para leer el contenido en Web/Móvil
      );

      if (result != null && result.files.single.bytes != null) {
        isLoading.value = true;
        
        // 2. Decodificar los bytes a un String (Texto)
        final csvString = utf8.decode(result.files.single.bytes!);

        // 3. Mandarlo a la Capa de Datos para procesarlo
        await repository.importGroupsFromCsv(courseId, csvString);

        if (Get.context != null) {
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            const SnackBar(content: Text('¡Grupos importados exitosamente!'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> importCsvData(String courseId, String csvString) async {
    try {
      isLoading.value = true;
      print("Importando grupos desde CSV...");
      await repository.importGroupsFromCsv(courseId, csvString);
      print("Grupos importados exitosamente");
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(content: Text('¡Grupos importados exitosamente!'), backgroundColor: Colors.green),
        );
      }

      if (Get.isRegistered<CategoryController>()) {
        Get.find<CategoryController>().loadCategories(courseId);
      }
    } catch (e) {
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

}