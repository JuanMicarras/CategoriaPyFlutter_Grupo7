import 'package:get/get.dart';
import 'package:peer_sync/features/course/ui/views/teacher_courses_page.dart';
import 'package:peer_sync/features/teacher/ui/views/teacher_home_page.dart';
import 'package:peer_sync/features/teacher/ui/views/teacher_profile_page.dart';

class TeacherNavigationHelpers {
  // Si los profesores también necesitan inicializar dependencias al navegar, lo pones aquí
  static void ensureTeacherDependencies() {
    // Ejemplo: Si necesitas Get.put de algo global para el profe
  }

  static void handleNavTap(int index) {
    ensureTeacherDependencies();

    if (index == 0) {
      Get.offAll(() => const TeacherCoursesPage());
    } else if (index == 1) {
      Get.offAll(() => const TeacherHomePage());
    } else if (index == 2) {
      Get.offAll(() => const TeacherProfilePage());
    }
  }
}