import 'package:flutter/material.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/widgets/create_activity_modal.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';

class CategoryDetailPage extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const CategoryDetailPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  void openCreateActivityModal(BuildContext context) {
    final controller = Get.find<EvaluationController>();

    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: Obx(() => CreateActivityModal(
            nameController: controller.nameController,
            startDateController: controller.startDateController,
            endDateController: controller.endDateController,
            startTimeController: controller.startTimeController,
            endTimeController: controller.endTimeController,
            isPublic: controller.isVisible.value,
            onPublicChanged: (val) => controller.isVisible.value = val,
            onCancel: () => Get.back(),
            onCreate: () {
              if (!controller.isLoading.value) {
                controller.saveActivity(categoryId); // 👈 Ya tiene acceso al ID
                Get.back(); 
              }
            },
            onTapStartDate: () => controller.pickStartDate(context),
            onTapEndDate: () => controller.pickEndDate(context),
          )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      
      // 👇 2. Agregamos el botón flotante
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
          categoryName, 
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
      body: Center(
        child: Text(
          "Aquí irían los grupos de la categoría con ID:\n$categoryId",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }
}