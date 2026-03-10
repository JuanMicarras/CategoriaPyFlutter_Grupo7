import 'package:peer_sync/features/product/data/datasources/local/local_product_source.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';

import 'central.dart';
import 'core/themes/app_theme.dart';

import 'features/auth/data/datasources/remote/authentication_source_service.dart';
import 'features/auth/data/datasources/remote/i_authentication_source.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/domain/repositories/i_auth_repository.dart';
import 'features/auth/ui/controllers/auth_controller.dart';
import 'features/product/data/datasources/i_remote_product_source.dart';
import 'features/product/data/repositories/product_repository.dart';
import 'features/product/domain/repositories/i_product_repository.dart';
import 'features/product/ui/viewmodels/product_controller.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';

import 'features/auth/ui/views/login_page.dart';
import 'features/auth/ui/views/signup_page.dart';
import 'features/home/ui/views/home_page.dart';

void main() {
  Loggy.initLoggy(logPrinter: const PrettyPrinter(showColors: true));

  Get.put(http.Client(), tag: 'apiClient');

  // Auth
  Get.put<IAuthenticationSource>(AuthenticationSourceService());
  Get.put<IAuthRepository>(AuthRepositoryImpl());
  Get.put(AuthController(repository: Get.find()));

  // Product
  //Get.put<IProductSource>(
  //  RemoteProductSource(Get.find<http.Client>(tag: 'apiClient')),
  //);
  Get.put<IProductSource>(LocalProductSource());
  Get.put<IProductRepository>(ProductRepository(Get.find()));
  Get.lazyPut(() => ProductController(Get.find()));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Clean template',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      debugShowCheckedModeBanner: false,

      initialRoute: '/',

      getPages: [
        GetPage(name: '/', page: () => const Central()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/signup', page: () => SignUpPage()),
        GetPage(name: '/home', page: () => const HomePage()),
      ],
    );
  }
}
