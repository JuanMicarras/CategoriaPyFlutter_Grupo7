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
  final endDate = DateTime.now().add(const Duration(days: 7)).obs;
  final startTime = Rxn<TimeOfDay>();
  final endTime = Rxn<TimeOfDay>();

  final isVisible = true.obs;

  EvaluationController(this.repository);

  // Método para guardar en Base de Datos
  Future<bool> saveActivity(String categoryId) async {
    try {
      if (nameController.text.trim().isEmpty) {
        _showMessage('El nombre de la actividad es obligatorio', Colors.orange);
        return false;
      }
      if (startTime.value == null || endTime.value == null) {
        _showMessage(
          'Debes seleccionar la hora de inicio y fin',
          Colors.orange,
        );
        return false;
      }

      isLoading.value = true;
      DateTime finalStartDate = DateTime(
        startDate.value.year,
        startDate.value.month,
        startDate.value.day,
        startTime.value!.hour,
        startTime.value!.minute,
      );

      DateTime finalEndDate = DateTime(
        endDate.value.year,
        endDate.value.month,
        endDate.value.day,
        endTime.value!.hour,
        endTime.value!.minute,
      );
      if (finalStartDate.isAfter(finalEndDate) ||
          finalStartDate.isAtSameMomentAs(finalEndDate)) {
        _showMessage('La fecha de inicio debe ser anterior a la de fin', Colors.redAccent);
        isLoading.value = false;
        return false;
      }

      await repository.createActivity(
        categoryId: categoryId,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        startDate: finalStartDate,
        endDate: finalEndDate,
        visibility: isVisible.value,
      );

      Get.back(); // Cerramos el modal/pantalla
      _showMessage('Actividad creada correctamente', Colors.green);

      // Limpiamos el formulario para la próxima vez
      nameController.clear();
      descriptionController.clear();
      isLoading.value = false;
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
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

  void _showMessage(String message, Color color) {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: color,
        ),
      );
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
      startTime.value = picked;
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
      endTime.value = picked;
      endTimeController.text = picked.format(context);
    }
  }
}
