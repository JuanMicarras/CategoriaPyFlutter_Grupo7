import 'package:flutter/material.dart';
import 'package:peer_sync/core/widgets/graph.dart';
import 'package:peer_sync/core/widgets/curses_home.dart';
import 'package:peer_sync/core/widgets/activities_home.dart';
import 'package:peer_sync/core/themes/app_theme.dart';

class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

  void openNotifications() {
    print("Abrir notificaciones");
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 40, left: 25, right: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Home",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        "Contenido Reciente",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  IconButton(
                    icon: Icon(
                      Icons.notifications_none,
                      size: 28,
                      color: theme.colorScheme.onSurface,
                    ),
                    onPressed: openNotifications,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            EvaluationCard(),

            const SizedBox(height: 20),

            CoursesSection(),

            const SizedBox(height: 30),

            ActivitiesSection(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
