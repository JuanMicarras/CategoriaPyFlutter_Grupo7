import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/features/evaluation/domain/models/activity.dart';
import '../../domain/repositories/i_evaluation_repository.dart';

class EvaluationController extends GetxController {
  final IEvaluationRepository repository;

  final isLoading = false.obs;

  // Formulario de actividades
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();

  final startDate = DateTime.now().obs;
  final endDate = DateTime.now().add(const Duration(days: 7)).obs;
  final startTime = Rxn<TimeOfDay>();
  final endTime = Rxn<TimeOfDay>();

  final isVisible = true.obs;

  // Actividades de una categoría específica
  final activities = <Activity>[].obs;
  final isLoadingActivities = false.obs;

  // 1. Getter que devuelve la lista ordenada automáticamente
  List<Activity> get sortedActivities {
    final sorted = List<Activity>.from(activities);

    sorted.sort((a, b) {
      final priorityA = _getActivityPriority(a);
      final priorityB = _getActivityPriority(b);

      if (priorityA != priorityB) return priorityA.compareTo(priorityB);
      if (priorityA == 0) return a.endDate.compareTo(b.endDate);
      if (priorityA == 1) return a.startDate.compareTo(b.startDate);
      return b.endDate.compareTo(a.endDate);
    });

    return sorted;
  }

  // Helper privado para la prioridad
  int _getActivityPriority(Activity activity) {
    final now = DateTime.now();
    if (now.isAfter(activity.endDate)) return 2; // Vencida
    if (now.isBefore(activity.startDate)) return 1; // Pendiente (futuro)
    return 0; // Activa
  }

  // 2. Función que formatea toda la UI para que la vista no tenga que pensar
  ({
    String month,
    String day,
    String statusLabel,
    String statusDetail,
    bool isExpired,
    bool isPending,
    bool isActive,
  }) getActivityUIData(Activity activity) {
    final now = DateTime.now();
    final isExpired = now.isAfter(activity.endDate);
    final isPending = now.isBefore(activity.startDate);
    final isActive = !isExpired && !isPending;

    const monthNames = ['ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'];

    // Si está pendiente usamos la fecha de inicio, si no, la de fin.
    final targetDate = isPending ? activity.startDate : activity.endDate;
    
    final monthStr = monthNames[targetDate.month - 1];
    final dayStr = targetDate.day.toString();

    // Lógica de hora
    final hour = targetDate.hour > 12 ? targetDate.hour - 12 : (targetDate.hour == 0 ? 12 : targetDate.hour);
    final amPm = targetDate.hour >= 12 ? 'PM' : 'AM';
    final minute = targetDate.minute.toString().padLeft(2, '0');
    final timeStr = "$hour:$minute $amPm";

    // Textos de estado
    String label;
    String detail;

    if (isExpired) {
      label = 'Vencida';
      detail = '• Cierre: $dayStr $monthStr $timeStr';
    } else if (isPending) {
      label = 'Próximamente';
      detail = '• Abre: $dayStr $monthStr $timeStr';
    } else {
      label = 'Pendiente'; // Significa "Pendiente de entregar / En curso"
      detail = '• Cierre: $dayStr $monthStr $timeStr';
    }

    return (
      month: monthStr,
      day: dayStr,
      statusLabel: label,
      statusDetail: detail,
      isExpired: isExpired,
      isPending: isPending,
      isActive: isActive,
    );
  }
  
  // --- LÓGICA DE UI PARA EL PROFESOR ---

  ({
    String month,
    String day,
    String statusTag,
    String statusDetail,
    bool isExpired,
  }) getTeacherActivityUIData(Activity activity) {
    final now = DateTime.now();
    final isExpired = now.isAfter(activity.endDate);
    final isPending = now.isBefore(activity.startDate);

    const monthNames = ['ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'];
    final monthStr = monthNames[activity.endDate.month - 1];
    final dayStr = activity.endDate.day.toString();

    // Lógica de hora
    final hour = activity.endDate.hour > 12 ? activity.endDate.hour - 12 : (activity.endDate.hour == 0 ? 12 : activity.endDate.hour);
    final amPm = activity.endDate.hour >= 12 ? 'PM' : 'AM';
    final minute = activity.endDate.minute.toString().padLeft(2, '0');
    final timeStr = "$hour:$minute $amPm";

    // Textos de estado específicos para el profesor
    String statusTag = isExpired ? "Finalizada" : (isPending ? "Programada" : "En curso");
    
    String statusDetail = "";
    if (!activity.visibility) {
      statusDetail = "• Oculta (Borrador)";
    } else {
      statusDetail = "• Cierra $timeStr";
    }

    return (
      month: monthStr,
      day: dayStr,
      statusTag: statusTag,
      statusDetail: statusDetail,
      isExpired: isExpired,
    );
  }
  
  // Variables para la vista del profesor
  final teacherActivities = <Activity>[].obs;
  final isLoadingTeacherActivities = false.obs;

  // Conteo de actividades activas por categoría
  final activeActivitiesCountByCategory = <String, int>{}.obs;
  final loadingActiveCountByCategory = <String, bool>{}.obs;

  // Preview para Home
  final homeActivities = <Activity>[].obs;
  final isLoadingHomeActivities = false.obs;

  EvaluationController(this.repository);

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

      final finalStartDate = DateTime(
        startDate.value.year,
        startDate.value.month,
        startDate.value.day,
        startTime.value!.hour,
        startTime.value!.minute,
      );

      final finalEndDate = DateTime(
        endDate.value.year,
        endDate.value.month,
        endDate.value.day,
        endTime.value!.hour,
        endTime.value!.minute,
      );

      if (finalStartDate.isAfter(finalEndDate) ||
          finalStartDate.isAtSameMomentAs(finalEndDate)) {
        _showMessage(
          'La fecha de inicio debe ser anterior a la de fin',
          Colors.redAccent,
        );
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

      Get.back();
      _showMessage('Actividad creada correctamente', Colors.green);

      nameController.clear();
      descriptionController.clear();
      startDateController.clear();
      endDateController.clear();
      startTimeController.clear();
      endTimeController.clear();

      startDate.value = DateTime.now();
      endDate.value = DateTime.now().add(const Duration(days: 7));
      startTime.value = null;
      endTime.value = null;
      isVisible.value = true;

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
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2300),
    );

    if (picked != null) {
      startDate.value = picked;
      startDateController.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  Future<void> pickEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      endDate.value = picked;
      endDateController.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  Future<void> pickStartTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      startTime.value = picked;
      startTimeController.text = picked.format(context);
    }
  }

  Future<void> pickEndTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      endTime.value = picked;
      endTimeController.text = picked.format(context);
    }
  }

  Future<void> loadActivities(String categoryId) async {
    try {
      isLoadingActivities.value = true;

      final result = await repository.getActivitiesByCategory(categoryId);

      final visibleActivities = result
          .where((act) => act.visibility == true)
          .toList();

      activities.assignAll(visibleActivities);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar las actividades: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoadingActivities.value = false;
    }
  }

  Future<void> loadTeacherActivities(String categoryId) async {
    try {
      isLoadingTeacherActivities.value = true;

      final result = await repository.getActivitiesByCategory(categoryId);

      // El profesor ve todo, así que asignamos la lista completa
      teacherActivities.assignAll(result);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar las actividades: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoadingTeacherActivities.value = false;
    }
  }

  Future<void> loadActiveActivitiesCount(String categoryId) async {
    if (loadingActiveCountByCategory[categoryId] == true) return;

    try {
      loadingActiveCountByCategory[categoryId] = true;
      loadingActiveCountByCategory.refresh();

      final result = await repository.getActivitiesByCategory(categoryId);

      final visibleActivities = result
          .where((act) => act.visibility == true)
          .toList();

      final now = DateTime.now();

      final activeCount = visibleActivities.where((activity) {
        final isExpired = now.isAfter(activity.endDate);
        final isPending = now.isBefore(activity.startDate);
        final isActive = !isExpired && !isPending;
        return isActive;
      }).length;

      activeActivitiesCountByCategory[categoryId] = activeCount;
      activeActivitiesCountByCategory.refresh();
    } catch (e) {
      activeActivitiesCountByCategory[categoryId] = 0;
      activeActivitiesCountByCategory.refresh();
    } finally {
      loadingActiveCountByCategory[categoryId] = false;
      loadingActiveCountByCategory.refresh();
    }
  }

  int getActiveActivitiesCount(String categoryId) {
    return activeActivitiesCountByCategory[categoryId] ?? 0;
  }

  String getActiveActivitySubtitle(String categoryId) {
    final count = getActiveActivitiesCount(categoryId);
    if (count == 0) return "Sin actividades activas";
    if (count == 1) return "1 actividad activa";
    return "$count actividades activas";
  }

  bool isLoadingActiveActivitiesCount(String categoryId) {
    return loadingActiveCountByCategory[categoryId] ?? false;
  }

  Future<void> loadHomeActivitiesPreview(List<String> categoryIds) async {
    if (categoryIds.isEmpty) {
      homeActivities.clear();
      return;
    }

    try {
      isLoadingHomeActivities.value = true;

      final List<Activity> allActivities = [];

      for (final categoryId in categoryIds) {
        final result = await repository.getActivitiesByCategory(categoryId);
        final visibleActivities = result
            .where((act) => act.visibility == true)
            .toList();
        allActivities.addAll(visibleActivities);
      }

      final now = DateTime.now();

      allActivities.sort((a, b) {
        final aExpired = now.isAfter(a.endDate);
        final bExpired = now.isAfter(b.endDate);

        if (aExpired != bExpired) {
          return aExpired ? 1 : -1;
        }

        if (!aExpired && !bExpired) {
          final aDistance = a.endDate.difference(now).abs();
          final bDistance = b.endDate.difference(now).abs();
          return aDistance.compareTo(bDistance);
        }

        return b.endDate.compareTo(a.endDate);
      });

      homeActivities.assignAll(allActivities.take(3).toList());
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar las actividades recientes: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoadingHomeActivities.value = false;
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

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    super.onClose();
  }
}
