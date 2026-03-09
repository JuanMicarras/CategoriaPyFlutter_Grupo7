import 'package:flutter/material.dart';

// importar navbar
import 'package:f_clean_template/core/widgets/navbar.dart';

// importar páginas
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

    return Scaffold(
      /// cambia dependiendo del index seleccionado
      body: pages[currentIndex],

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFAF95DE),
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
