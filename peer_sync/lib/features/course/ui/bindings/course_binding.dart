import 'package:get/get.dart';
import 'package:peer_sync/features/course/ui/viewmodels/course_controller.dart';
import 'package:peer_sync/features/course/domain/repositories/i_course_repository.dart';
import 'package:peer_sync/features/course/data/repositories/course_repository_impl.dart';
import 'package:peer_sync/features/course/data/datasources/remote/i_course_remote_source.dart';
import 'package:peer_sync/features/course/data/datasources/remote/course_remote_source_service.dart';
import 'package:peer_sync/features/auth/domain/repositories/i_auth_repository.dart';

class CourseBinding extends Bindings {
  @override
  void dependencies() {

    /// 🔥 REMOTE SOURCE (SIN TOKEN)
    Get.lazyPut<ICourseRemoteSource>(
      () => CourseRemoteSourceService(),
    );

    /// 🔥 REPOSITORY (INYECTAMOS AUTH REPO PARA SAFE REQUEST)
    Get.lazyPut<ICourseRepository>(
      () => CourseRepositoryImpl(
        Get.find<ICourseRemoteSource>(),
        Get.find<IAuthRepository>(), // 👈 CLAVE
      ),
    );

    /// 🔥 CONTROLLER
    Get.lazyPut(
      () => CourseController(repository: Get.find()),
    );
  }
}
