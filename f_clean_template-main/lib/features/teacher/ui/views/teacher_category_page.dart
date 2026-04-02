import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/widgets/category_card.dart';
import 'package:peer_sync/core/widgets/create_category_modal.dart';
import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart';
import 'package:peer_sync/features/category/ui/views/category_detail_page.dart';
import 'package:peer_sync/features/evaluation/ui/views/create_activity_page.dart';
import 'package:peer_sync/features/groups/ui/viewmodels/groups_controller.dart';

class CourseDetailPage extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const CourseDetailPage({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  final categoryController = Get.find<CategoryController>();

  @override
  void initState() {
    super.initState();

    /// 🔥 CARGAR CATEGORÍAS DESDE BD (UNA SOLA VEZ)
    categoryController.loadCategories(widget.courseId);
  }

  void openCreateCategoryModal(BuildContext context) {
    final groupsController = Get.find<GroupsController>();
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: CreateGroupCategoryModal(
            onCancel: () {
              if (!groupsController.isLoading.value) {
                Get.back();
              }
            },
            onCreate: () {
              print("Categoría manual creada");
              Get.back();
            },
            onCsvSelected: (file) async {
              if (file != null && file.bytes != null) {
                final csvString = utf8.decode(file.bytes!);

                Get.back();

                /// 🔥 AQUÍ luego puedes conectar a tu API
                print("CSV enviado: $csvString");

                await groupsController.importCsvData(
                  widget.courseId,
                  csvString,
                );

                /// 🔥 RECARGAR LISTA
                await categoryController.loadCategories(widget.courseId);
              } else {
                Get.snackbar(
                  'Error',
                  'No se pudo leer el archivo seleccionado',
                  backgroundColor: Colors.redAccent,
                  colorText: Colors.white,
                );
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupsController = Get.find<GroupsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      /// 🔥 FAB DINÁMICO
      floatingActionButton: Obx(
        () => groupsController.isLoading.value
            ? const CircularProgressIndicator() // Si está cargando, mostramos un círculo
            : FloatingActionButton(
                onPressed: () {
                  openCreateCategoryModal(context);
                },
                backgroundColor: AppTheme.secondaryColor,
                child: const Icon(Icons.add),
              ),
      ),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
        title: Text(
          widget.courseTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none),
          ),
        ],
      ),

      /// 🔥 BODY DINÁMICO DESDE BD
      body: Obx(() {
        final categories = categoryController.categories;

        /// 🔄 LOADING INICIAL
        if (categoryController.isLoading.value && categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 45),
              child: Text(
                "Categorias de Grupos",
                style: AppTheme.bodyM.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor300,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 🔥 LISTA DINÁMICA
            ...categories.map((item) {
              return Column(
                children: [
                  Align(
                    alignment: Alignment.center,
                    
                    child: GestureDetector(
                      onTap: () {
                        // Navegación a la vista de detalle que hicimos antes
                        Get.to(() => CategoryDetailPage(
                          categoryId: item.id, 
                          categoryName: item.name,
                        ));
                      },
                      child: ProjectCategoryCard(
                        title: item.name,
                        subtitle: "Grupo",
                        leadingIcon: Icons.group,
                      ),
                    ),
                  ),
                  
                  // 👇 BOTÓN DE PRUEBA PARA CREAR ACTIVIDAD
                  TextButton.icon(
                    onPressed: () {
                      Get.to(() => CreateActivityPage(
                        categoryId: item.id,      // Sacamos el ID real del iterador
                        categoryName: item.name,  // Sacamos el nombre real
                      ));
                    },
                    icon: const Icon(Icons.add_task, color: AppTheme.secondaryColor),
                    label: const Text(
                      "Crear Actividad", 
                      style: TextStyle(color: AppTheme.secondaryColor)
                    ),
                  ),
                  
                  const SizedBox(height: 14),
                ],
              );
            }).toList(),
          ],
        );
      }),
    );
  }
}
