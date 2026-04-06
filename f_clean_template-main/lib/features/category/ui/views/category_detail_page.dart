import 'package:flutter/material.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/utils/loading_overlay.dart';
import 'package:peer_sync/core/widgets/activity_card.dart';
import 'package:peer_sync/core/widgets/create_activity_modal.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/evaluation/ui/views/teacher_report_page.dart';

class CategoryDetailPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryDetailPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  final EvaluationController controller = Get.find<EvaluationController>();

  @override
  void initState() {
    super.initState();
    // Apenas entramos, le decimos al controlador que cargue las actividades
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadTeacherActivities(widget.categoryId);
    });
  }

  void openCreateActivityModal(BuildContext context) {
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: Obx(() => CreateActivityModal(
            nameController: controller.nameController,
            startDateController: controller.startDateController, // Usa los controllers de fecha que tengas
            endDateController: controller.endDateController,
            startTimeController: controller.startTimeController,
            endTimeController: controller.endTimeController,
            isPublic: controller.isVisible.value,
            onPublicChanged: (val) => controller.isVisible.value = val,
            onCancel: () => Get.back(),
            onCreate: () async {
              if (!controller.isLoading.value) {
                LoadingOverlay.show("Guardando actividad...");
                bool success = await controller.saveActivity(widget.categoryId); 
                LoadingOverlay.hide();
                if (success) {
                  Get.back(); // Cerramos el modal
                  // ¡MAGIA! Recargamos la lista para que la nueva actividad aparezca de inmediato
                  controller.loadTeacherActivities(widget.categoryId);
                }
              }
            },
            onTapStartDate: () => controller.pickStartDate(context),
            onTapEndDate: () => controller.pickEndDate(context),
            onTapStartTime: () => controller.pickStartTime(context),
            onTapEndTime: () => controller.pickEndTime(context),
          )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openCreateActivityModal(context);
        },
        backgroundColor: AppTheme.secondaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
        title: Text(
          widget.categoryName, 
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
      
      // Cuerpo Reactivo con GetX
      body: Obx(() {
        if (controller.isLoadingTeacherActivities.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.teacherActivities.isEmpty) {
          return const Center(
            child: Text(
              "No hay actividades creadas aún.\nToca el botón '+' para comenzar.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          );
        }

        // Construimos la lista con las tarjetas de tu compañera
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.teacherActivities.length,
          itemBuilder: (context, index) {
            final activity = controller.teacherActivities[index];
            final now = DateTime.now();
            
            // Lógica de estado para el profesor
            final isExpired = now.isAfter(activity.endDate);
            final isPending = now.isBefore(activity.startDate);
            
            // Formateo de fecha
            const monthNames = ['ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'];
            final monthStr = monthNames[activity.endDate.month - 1];
            final dayStr = activity.endDate.day.toString();
            
            final hour = activity.endDate.hour > 12 ? activity.endDate.hour - 12 : (activity.endDate.hour == 0 ? 12 : activity.endDate.hour);
            final amPm = activity.endDate.hour >= 12 ? 'PM' : 'AM';
            final minute = activity.endDate.minute.toString().padLeft(2, '0');
            final timeStr = "$hour:$minute $amPm";

            // Mensajes adaptados al profesor
            String statusTag = isExpired ? "Finalizada" : (isPending ? "Programada" : "En curso");
            
            String statusDetail = "";
            if (!activity.visibility) {
              statusDetail = "• Oculta (Borrador)";
            } else {
              statusDetail = "• Cierra $timeStr";
            }

            final dateBgColor = isExpired ? Colors.grey[200]! : const Color(0xFFE5DBF5);
            final dateTextColor = isExpired ? Colors.grey[600]! : const Color(0xFF8761BE);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ActivityStatusCard(
                title: activity.name,
                month: monthStr,
                day: dayStr,
                statusTag: statusTag,       // <-- Aquí va la palabra clave
                statusDetail: statusDetail, // <-- Aquí va el resto de la info
                dateBgColor: dateBgColor,
                dateTextColor: dateTextColor,
                onTap: () {
                  // ¡Navegamos a la vista maestra del reporte!
                  Get.to(() => TeacherReportPage(
                    activityId: activity.id,
                    activityName: activity.name,
                    categoryId: widget.categoryId,
                  ));
                },
              ),
            );
          },
        );
      }),
    );
  }
}