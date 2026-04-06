import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
// Ajusta esta ruta según la ubicación real de tu controlador:
import '../viewmodels/evaluation_controller.dart'; 
//TODO ESTA VISTA NO SE USA, SE PUEDE BORRAR SI SE QUIERE, SOLO ES UN EJEMPLO DE CÓMO PODRÍA SER LA PANTALLA PARA CREAR UNA ACTIVIDAD NUEVA DENTRO DE UNA CATEGORÍA. 
class CreateActivityPage extends StatelessWidget {
  // Pedimos el ID de la categoría a la que pertenecerá esta actividad
  final String categoryId;
  final String categoryName; 

  const CreateActivityPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    // Obtenemos el controlador que inyectamos en main.dart
    final controller = Get.find<EvaluationController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
        title: Text(
          'Nueva Actividad en $categoryName',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de Nombre
            Text("Nombre de la Actividad", style: AppTheme.bodyM.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: controller.nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                hintText: 'Ej. Proyecto Final',
              ),
            ),
            const SizedBox(height: 20),

            // Campo de Descripción
            Text("Descripción (Opcional)", style: AppTheme.bodyM.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: controller.descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                hintText: 'Detalles de la evaluación...',
              ),
            ),
            const SizedBox(height: 20),

            // Selectores de Fecha (Usando Obx para que reaccionen)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Fecha Inicio", style: AppTheme.bodyM.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Obx(() => InkWell(
                        onTap: () => controller.pickStartDate(context),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${controller.startDate.value.toLocal()}'.split(' ')[0]),
                              const Icon(Icons.calendar_today, size: 18, color: AppTheme.primaryColor),
                            ],
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Fecha Fin", style: AppTheme.bodyM.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Obx(() => InkWell(
                        onTap: () => controller.pickEndDate(context),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${controller.endDate.value.toLocal()}'.split(' ')[0]),
                              const Icon(Icons.calendar_today, size: 18, color: AppTheme.primaryColor),
                            ],
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Switch de Visibilidad
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Obx(() => SwitchListTile(
                title: const Text('Visible para los estudiantes', style: TextStyle(fontWeight: FontWeight.w500)),
                activeColor: AppTheme.primaryColor,
                value: controller.isVisible.value,
                onChanged: (val) => controller.isVisible.value = val,
              )),
            ),
            const SizedBox(height: 40),

            // Botón de Guardar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                        // AQUÍ LLAMAMOS AL CONTROLADOR PARA GUARDAR EN ROBLE
                        controller.saveActivity(categoryId);
                      },
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Crear Actividad', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              )),
            ),
          ],
        ),
      ),
    );
  }
}