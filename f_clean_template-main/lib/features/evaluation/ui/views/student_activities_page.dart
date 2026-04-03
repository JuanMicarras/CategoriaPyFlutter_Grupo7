import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/widgets/activity_card.dart';
import 'package:peer_sync/features/evaluation/ui/views/student_evaluation_page.dart';
import '../viewmodels/evaluation_controller.dart';

class StudentActivitiesPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const StudentActivitiesPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<StudentActivitiesPage> createState() => _StudentActivitiesPageState();
}

class _StudentActivitiesPageState extends State<StudentActivitiesPage> {
  final EvaluationController controller = Get.find<EvaluationController>();

  @override
  void initState() {
    super.initState();
    // Apenas la pantalla se abre, mandamos a cargar las actividades
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadActivities(widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
        title: Text(
          'Actividades: ${widget.categoryName}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingActivities.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.activities.isEmpty) {
          return const Center(child: Text('No hay actividades disponibles.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.activities.length,
          itemBuilder: (context, index) {
            final activity = controller.activities[index];
            final now = DateTime.now();

            // LÓGICA DE ESTADO
            final isExpired = now.isAfter(activity.endDate);
            final isPending = now.isBefore(activity.startDate);
            final isActive = !isExpired && !isPending;

            // Usamos la fecha de fin (endDate) que es la que le importa al estudiante
            // Nombres de los meses
            const monthNames = [
              'ENE',
              'FEB',
              'MAR',
              'ABR',
              'MAY',
              'JUN',
              'JUL',
              'AGO',
              'SEP',
              'OCT',
              'NOV',
              'DIC',
            ];

            // 1. Datos para el cuadrito morado/gris (Siempre usamos endDate o startDate según prefieras, aquí mantengo endDate como lo tenías)
            final monthStr = monthNames[activity.endDate.month - 1];
            final dayStr = activity.endDate.day.toString();

            // 2. Calcular Hora exacta de CIERRE (endDate)
            final endMonth = monthNames[activity.endDate.month - 1];
            final endHour = activity.endDate.hour > 12
                ? activity.endDate.hour - 12
                : (activity.endDate.hour == 0 ? 12 : activity.endDate.hour);
            final endAmPm = activity.endDate.hour >= 12 ? 'PM' : 'AM';
            final endMinute = activity.endDate.minute.toString().padLeft(
              2,
              '0',
            );
            final endTimeStr = "$endHour:$endMinute $endAmPm";

            // 3. Calcular Hora exacta de APERTURA (startDate)
            final startMonth = monthNames[activity.startDate.month - 1];
            final startDay = activity.startDate.day.toString();
            final startHour = activity.startDate.hour > 12
                ? activity.startDate.hour - 12
                : (activity.startDate.hour == 0 ? 12 : activity.startDate.hour);
            final startAmPm = activity.startDate.hour >= 12 ? 'PM' : 'AM';
            final startMinute = activity.startDate.minute.toString().padLeft(
              2,
              '0',
            );
            final startTimeStr = "$startHour:$startMinute $startAmPm";

            // 4. Armar el texto de estado completo con Fecha + Hora
            final statusText = isExpired
                ? "Vencida • Cierre: $dayStr $endMonth a las $endTimeStr"
                : (isPending
                      ? "Próximamente • Abre: $startDay $startMonth a las $startTimeStr"
                      : "Pendiente • Cierre: $dayStr $endMonth a las $endTimeStr");

            // Colores (se mantiene igual)
            final dateBgColor = isExpired
                ? Colors.grey[200]!
                : const Color(0xFFE5DBF5);
            final dateTextColor = isExpired
                ? Colors.grey[600]!
                : const Color(0xFF8761BE);
            // 4. INYECTAMOS LOS DATOS EN EL WIDGET DE TU COMPAÑERA
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ActivityCard(
                // Asegúrate de importar el archivo donde quedó ActivityCard
                title: activity.name,
                month: monthStr,
                day: dayStr,
                statusText: statusText,
                dateBgColor: dateBgColor,
                dateTextColor: dateTextColor,
                onTap: () {
                  if (isActive || isExpired) {
                    Get.to(
                      () => StudentEvaluationPage(
                        activityId: activity.id,
                        activityName: activity.name,
                        categoryId: widget.categoryId, 
                        isExpired: isExpired,
                      ),
                    );
                  } else if (isExpired) {
                    Get.snackbar(
                      'Cerrada',
                      'Esta actividad ya finalizó.',
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                    );
                  } else {
                    Get.snackbar(
                      'Paciencia',
                      'Esta actividad aún no comienza.',
                      backgroundColor: Colors.blue,
                      colorText: Colors.white,
                    );
                  }
                },
              ),
            );
          },
        );
      }),
    );
  }

  // Widget auxiliar para no repetir código de fechas
  Widget _buildDateColumn(String label, DateTime date, bool isExpired) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isExpired ? Colors.grey : Colors.grey[500],
          ),
        ),
        Text(
          "${date.day}/${date.month}/${date.year}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isExpired ? Colors.grey[600] : Colors.black87,
          ),
        ),
      ],
    );
  }
}
