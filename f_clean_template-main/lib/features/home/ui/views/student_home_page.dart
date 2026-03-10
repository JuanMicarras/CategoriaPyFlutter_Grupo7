import 'package:flutter/material.dart';

class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

  void openNotifications() {
    print("Abrir notificaciones");
  }

  void openCourses() {
    print("Ver todos los cursos");
  }

  void openActivities() {
    print("Ver todas las actividades");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// HOME + CAMPANA
          Row(
            children: [

              const Text(
                "Home",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8F72C9),
                ),
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

          const Text(
            "Contenido Reciente",
            style: TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.w800,
              color: Color(0xFFCDBDEA),
            ),
          ),

          const SizedBox(height: 20),

          /// CURSOS
          Row(
            children: [

              const Text(
                "Cursos Agregados",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFAF95DE),
                ),
              ),

              const Spacer(),

              GestureDetector(
                onTap: openCourses,
                child: const Text(
                  "View All",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFAF95DE),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// ACTIVIDADES
          Row(
            children: [

              const Text(
                "Actividades Agregadas",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFAF95DE),
                ),
              ),

              const Spacer(),

              GestureDetector(
                onTap: openActivities,
                child: const Text(
                  "View All",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFAF95DE),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
