import 'package:flutter/material.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/widgets/course_card.dart';

class StudentCoursesPage extends StatelessWidget {
  const StudentCoursesPage({super.key});

  void openNotifications() {
    print("Abrir notificaciones");
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 40, left: 25, right: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text(
                        "Cursos",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      size: 28,
                      color: Color(0xFF110E47),
                    ),
                    onPressed: openNotifications,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /////////////////////////////////   CARD DE CURSO   /////////////////////////////////
            Column(
              children: [
                CourseCard(
                  title: "Programación Móvil",
                  progressText: "3 de 5 actividades",
                  progress: 0.6,
                  leadingIcon: Icons.phone_android,
                  projects: [
                    CourseProjectItem(
                      title: "Proyecto Flutter",
                      subtitle: "Entrega en 2 días",
                      onTap: () {
                        print("Abrir proyecto Flutter");
                      },
                    ),
                    CourseProjectItem(title: "UI App", subtitle: "En progreso"),
                  ],
                ),

                const SizedBox(height: 20),

                CourseCard(
                  title: "Bases de Datos",
                  progressText: "1 de 4 actividades",
                  progress: 0.25,
                  leadingIcon: Icons.storage,
                  projects: [
                    CourseProjectItem(
                      title: "Modelo ER",
                      subtitle: "Pendiente",
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
