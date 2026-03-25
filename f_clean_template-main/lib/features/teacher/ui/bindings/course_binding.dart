import 'package:get/get.dart';
import 'package:peer_sync/features/teacher/ui/viewmodels/course_controller.dart';
import 'package:peer_sync/features/teacher/domain/repositories/i_course_repository.dart';
import 'package:peer_sync/features/teacher/data/repositories/course_repository_impl.dart';
import 'package:peer_sync/features/teacher/data/remote/i_course_remote_source.dart';
import 'package:peer_sync/features/teacher/data/remote/course_remote_source_service.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';

class CourseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CourseRemoteSource>(() {
      final authController = Get.find<AuthController>();

      final token = authController.user?.tokenA;

      return CourseRemoteSourceService(token: token!);
    });

    Get.lazyPut<ICourseRepository>(() => CourseRepositoryImpl(Get.find()));

    Get.lazyPut(() => CourseController(repository: Get.find()));
  }
}
