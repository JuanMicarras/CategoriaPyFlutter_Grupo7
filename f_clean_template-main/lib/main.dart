import 'package:peer_sync/features/category/ui/bindings/category_binding.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/teacher_report_controller.dart';
import 'package:peer_sync/features/groups/data/datasources/remote/groups_remote_source.dart';
import 'package:peer_sync/features/groups/data/datasources/remote/i_groups_remote_source.dart';
import 'package:peer_sync/features/groups/data/repositories/groups_repository_impl.dart';
import 'package:peer_sync/features/groups/domain/repositories/i_groups_repository.dart';
import 'package:peer_sync/features/groups/ui/viewmodels/groups_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';

import 'package:peer_sync/features/notifications/data/datasources/remote/notification_remote_source.dart';
import 'package:peer_sync/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:peer_sync/features/notifications/domain/repositories/i_notification_repository.dart';
import 'package:peer_sync/features/notifications/ui/viewmodels/notification_controller.dart';
import 'package:peer_sync/features/student/ui/views/student_home_page.dart';
import 'package:peer_sync/features/teacher/ui/views/teacher_home_page.dart';

import 'central.dart';
import 'core/themes/app_theme.dart';

import 'features/auth/data/datasources/remote/authentication_source_service.dart';
import 'features/auth/data/datasources/remote/i_authentication_source.dart';

import 'features/evaluation/data/datasources/remote/i_evaluation_remote_source.dart';
import 'features/evaluation/data/datasources/remote/evaluation_remote_source.dart';
import 'features/evaluation/domain/repositories/i_evaluation_repository.dart';
import 'features/evaluation/data/repositories/evaluation_repository_impl.dart';
import 'features/evaluation/ui/viewmodels/evaluation_controller.dart';

import 'features/auth/domain/repositories/i_auth_repository.dart';
import 'features/auth/ui/viewmodels/auth_controller.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/course/ui/bindings/course_binding.dart';

import 'features/auth/ui/views/login_page.dart';
import 'features/auth/ui/views/signup_page.dart';


void main() {
  Loggy.initLoggy(logPrinter: const PrettyPrinter(showColors: true));

  Get.put(http.Client(), tag: 'apiClient');

  // Auth
  Get.put<IAuthenticationSource>(AuthenticationSourceService());
  Get.put<IAuthRepository>(AuthRepositoryImpl(Get.find()));
  Get.put<AuthController>(AuthController(repository: Get.find()));

  Get.put<IGroupsRemoteSource>(GroupsRemoteSource());
  Get.put<IGroupsRepository>(GroupsRepositoryImpl(Get.find()));
  Get.put<GroupsController>(GroupsController(Get.find()));

  // Inyecciones de Evaluation (Actividades)
  Get.put<IEvaluationRemoteSource>(EvaluationRemoteSource());
  Get.put<IEvaluationRepository>(EvaluationRepositoryImpl(Get.find()));
  Get.put<EvaluationController>(EvaluationController(Get.find()));

  Get.put<TeacherReportController>(TeacherReportController(Get.find()));

  Get.put(NotificationRemoteSource());
  Get.put<INotificationRepository>(NotificationRepositoryImpl(Get.find()));
  Get.put(NotificationController(Get.find()));
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PeerSync',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      debugShowCheckedModeBanner: false,

      initialRoute: '/',

      getPages: [
        GetPage(name: '/', page: () => const Central()),
        GetPage(
          name: '/login',
          page: () => LoginPage(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          opaque: true,
        ),
        GetPage(
          name: '/signup',
          page: () => SignUpPage(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          opaque: true,
        ),
        GetPage(
          name: '/homeStudent',
          page: () => const StudentHomePage(),
          binding: BindingsBuilder(() {
            CourseBinding().dependencies();
            CategoryBinding().dependencies();
          }),
        ),
        GetPage(
          name: '/homeTeacher',
          page: () => const TeacherHomePage(),
          binding: BindingsBuilder(() {
            CourseBinding().dependencies();
            CategoryBinding().dependencies();
          }),
        ),
      ],
    );
  }
}
