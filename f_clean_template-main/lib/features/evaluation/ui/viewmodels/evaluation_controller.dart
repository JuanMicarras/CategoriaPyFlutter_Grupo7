import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/repositories/i_evaluation_repository.dart';

class EvaluationController extends GetxController {
  final IEvaluationRepository repository;
  
  final isLoading = false.obs;

  // Variables Reactivas para el formulario
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  
  // Inicializamos las fechas por defecto (Hoy y Mañana)
  final startDate = DateTime.now().obs;
  final endDate = DateTime.now().add(const Duration(days: 1)).obs;
  
  final isVisible = true.obs;

  EvaluationController(this.repository);

  // Método para guardar en Base de Datos
  Future<void> saveActivity(String categoryId) async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'El nombre es obligatorio', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (endDate.value.isBefore(startDate.value)) {
      Get.snackbar('Error', 'La fecha de fin no puede ser antes de la fecha de inicio', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      
      await repository.createActivity(
        categoryId: categoryId,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        startDate: startDate.value,
        endDate: endDate.value,
        visibility: isVisible.value,
      );

      Get.back(); // Cerramos el modal/pantalla
      Get.snackbar('¡Éxito!', 'Actividad creada correctamente', backgroundColor: Colors.green, colorText: Colors.white);
      
      // Limpiamos el formulario para la próxima vez
      nameController.clear();
      descriptionController.clear();

    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''), backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickStartDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2300),
    );
    if (picked != null) {
      startDate.value = picked; 
      startDateController.text = "${picked.day}/${picked.month}/${picked.year}"; 
    }
  }

  Future<void> pickEndDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), 
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      endDate.value = picked; 
      endDateController.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  Future<void> pickStartTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      // Opcional: si tienes una variable reactiva para la hora, la guardas aquí
      // startTime.value = picked; 
      
      // format(context) convierte la hora a texto (ej. "14:30" o "2:30 PM") dependiendo de la configuración del celular
      startTimeController.text = picked.format(context); 
    }
  }

  // 3. Selector de Hora de Fin
  Future<void> pickEndTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      // Opcional: si tienes una variable reactiva para la hora, la guardas aquí
      // endTime.value = picked;
      
      // Actualizamos el controlador de texto para el Modal
      endTimeController.text = picked.format(context);
    }
  }
}