import 'package:flutter/material.dart';

class StudentCoursesPage extends StatelessWidget {
  const StudentCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 40, left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Cursos",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
