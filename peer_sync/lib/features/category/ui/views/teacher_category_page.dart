import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/utils/teacher_navigation_helpers.dart';
import 'package:peer_sync/core/utils/loading_overlay.dart';
import 'package:peer_sync/features/category/ui/views/category_detail_page.dart';
import 'package:peer_sync/features/category/ui/widgets/category_card.dart';
import 'package:peer_sync/core/widgets/navbar.dart';
import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart';
import 'package:peer_sync/features/category/ui/widgets/create_category_modal.dart';
import 'package:peer_sync/features/course/ui/viewmodels/course_controller.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/groups/ui/viewmodels/groups_controller.dart';
import 'package:peer_sync/features/notifications/ui/viewmodels/notification_controller.dart';
import 'package:peer_sync/features/notifications/ui/views/notifications_page.dart';

class TeacherCourseDetailPage extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const TeacherCourseDetailPage({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<TeacherCourseDetailPage> createState() =>
      _TeacherCourseDetailPageState();
}

class _TeacherCourseDetailPageState extends State<TeacherCourseDetailPage> {
  final CategoryController controller = Get.find<CategoryController>();
  final EvaluationController evaluationController =
      Get.find<EvaluationController>();
  final GroupsController groupsController = Get.find<GroupsController>();
  final CourseController courseController = Get.find<CourseController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.loadCategories(widget.courseId);

      for (final category in controller.categories) {
        evaluationController.loadActiveActivitiesCount(category.id);
      }
    });
  }

  void openCreateCategoryModal(BuildContext context) {
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: CreateGroupCategoryModal(
            onCancel: () {
              if (!groupsController.isLoading.value) Get.back();
            },
            onCreate: () => Get.back(),
            onCsvSelected: (file) async {
              if (file != null && file.bytes != null) {
                final csvString = utf8.decode(file.bytes!);

                Get.back();
                LoadingOverlay.show("Importando grupos y estudiantes...");

                try {
                  await groupsController.importCsvData(
                    widget.courseId,
                    csvString,
                  );

                  await controller.loadCategories(widget.courseId);

                  for (final category in controller.categories) {
                    evaluationController.loadActiveActivitiesCount(category.id);
                  }
                } finally {
                  LoadingOverlay.hide();
                }
              } else {
                Get.snackbar(
                  'Error',
                  'No se pudo leer el archivo seleccionado',
                  backgroundColor:
                      Theme.of(Get.context!).brightness == Brightness.light
                      ? const Color(0xFFD1B3FF)
                      : const Color(0xFF3A3260),
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
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: isLight
          ? const Color(0xFFF5F6FA)
          : AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: isLight
            ? const Color(0xFFF5F6FA)
            : AppTheme.darkBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: isLight ? AppTheme.primaryColor : AppTheme.darkTextPrimary,
        ),
        title: Text(
          widget.courseTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isLight ? AppTheme.primaryColor : AppTheme.darkTextPrimary,
          ),
        ),
        actions: [
          Obx(() {
            final notifController = Get.find<NotificationController>();
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_none,
                    size: 30,
                    color: isLight
                        ? AppTheme.primaryColor
                        : AppTheme.darkTextPrimary,
                  ),
                  onPressed: () => Get.to(() => const NotificationsPage()),
                ),
                if (notifController.unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color:
                            Theme.of(Get.context!).brightness ==
                                Brightness.light
                            ? const Color(0xFF3A2A6B)
                            : AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${notifController.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openCreateCategoryModal(context),
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AppTheme.secondaryColor
            : AppTheme.darkBorder,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        final categories = controller.categories;

        if (controller.isLoading.value && categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (categories.isEmpty) {
          return Center(
            child: Text(
              "Este curso no tiene categorías",
              style: TextStyle(
                color: isLight ? Colors.grey : AppTheme.darkTextMuted,
                fontSize: 16,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 10,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // TÍTULO DEL CÓDIGO
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 45),
                  child: Text(
                    "Código del curso",
                    style: AppTheme.bodyM.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isLight
                          ? AppTheme.primaryColor300
                          : AppTheme.darkTextPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // CARD DEL CÓDIGO
                Center(
                  child: Obx(() {
                    final code = courseController.getCodeById(widget.courseId);
                    if (code == null) return const SizedBox();

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: isLight ? Colors.white : AppTheme.darkCard,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isLight
                                ? Colors.black.withOpacity(0.05)
                                : Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            code.toString(),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isLight
                                  ? AppTheme.primaryColor
                                  : AppTheme.darkTextPrimary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: code.toString()),
                              );
                              Get.snackbar(
                                "Copiado",
                                "Código copiado al portapapeles",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: !isLight
                                    ? AppTheme.primaryColor
                                    : AppTheme.darkPrimarySoft,
                                colorText: !isLight
                                    ? Colors.white
                                    : Colors.black,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.copy,
                                color: isLight
                                    ? AppTheme.primaryColor
                                    : AppTheme.darkTextSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 30),

                // TÍTULO DE CATEGORÍAS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Text(
                    "Categorias de Grupos",
                    style: AppTheme.bodyM.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isLight
                          ? AppTheme.primaryColor300
                          : AppTheme.darkTextPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Lista de categorías
                ...categories.map((item) {
                  final subtitle = evaluationController
                      .getActiveActivitySubtitle(item.id);

                  return Column(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () {
                            Get.to(
                              () => CategoryDetailPage(
                                categoryId: item.id,
                                categoryName: item.name,
                              ),
                            );
                          },
                          child: ProjectCategoryCard(
                            title: item.name,
                            subtitle: subtitle,
                            leadingIcon: Icons.group,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: NavBar(
        currentIndex: 0,
        onTap: (index) => TeacherNavigationHelpers.handleNavTap(index),
      ),
    );
  }
}
