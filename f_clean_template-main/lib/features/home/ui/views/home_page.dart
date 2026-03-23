import 'package:flutter/material.dart';
import 'package:peer_sync/core/widgets/navbar.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'student_home_page.dart';
import 'student_courses_page.dart';
import 'student_profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int currentIndex = 1;

  /// lista de páginas que cambiarán con el navbar
  final List<Widget> pages = const [
    StudentCoursesPage(),
    StudentHomePage(),
    StudentProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Scaffold(
      /// cambia dependiendo del index seleccionado
      body: pages[currentIndex],
      backgroundColor: theme.colorScheme.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: theme.colorScheme.secondary,
        child: const Icon(Icons.add),
      ),

      /// navbar importado
      bottomNavigationBar: NavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
