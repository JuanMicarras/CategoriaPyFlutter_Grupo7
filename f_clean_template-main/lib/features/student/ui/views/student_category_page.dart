import 'package:flutter/material.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/widgets/category_card.dart';

class CourseDetailPage extends StatelessWidget {
  final String courseTitle;
  final String projectTitle;

  const CourseDetailPage({
    super.key,
    required this.courseTitle,
    required this.projectTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // 👈 fondo gris como imagen

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

          Align(
            alignment: Alignment.center,
            child: ProjectCategoryCard(
              title: "Proyecto CPU",
              subtitle: "3 integrantes • 0/3 done",
              leadingIcon: Icons.download,
            ),
          ),

          const SizedBox(height: 14),

          Align(
            alignment: Alignment.center,
            child: ProjectCategoryCard(
              title: "Proyecto CPU 2",
              subtitle: "3 integrantes • 0/3 done",
              leadingIcon: Icons.download,
            ),
          ),

          const SizedBox(height: 14),

          Align(
            alignment: Alignment.center,
            child: ProjectCategoryCard(
              title: "Proyecto CPU 3",
              subtitle: "3 integrantes • 0/3 done",
              leadingIcon: Icons.download,
            ),
          ),
        ],
      ),
    );
  }
}
