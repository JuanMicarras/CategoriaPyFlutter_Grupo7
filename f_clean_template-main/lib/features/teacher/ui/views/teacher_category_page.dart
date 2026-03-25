import 'package:flutter/material.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/widgets/category_card.dart';
import 'package:peer_sync/core/widgets/create_category_modal.dart';

class CourseDetailPage extends StatelessWidget {
  final String courseTitle;
  final List<Map<String, dynamic>> categories;

  const CourseDetailPage({
    super.key,
    required this.courseTitle,
    required this.categories,
  });

  void openCreateCategoryModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: CreateGroupCategoryModal(
              onCancel: () {
                Navigator.pop(context);
              },
              onCreate: () {
                print("Categoría creada");
                Navigator.pop(context);
              },
              onCsvSelected: (file) {
                print("CSV seleccionado: ${file?.name}");
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openCreateCategoryModal(context);
        },
        backgroundColor: AppTheme.secondaryColor,
        child: const Icon(Icons.add),
      ),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
        title: Text(
          courseTitle,
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

      body: Column(
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

          ...categories.map((item) {
            return Column(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: ProjectCategoryCard(
                    title: item["title"],
                    subtitle: item["subtitle"],
                    leadingIcon: item["icon"],
                  ),
                ),
                const SizedBox(height: 14),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}