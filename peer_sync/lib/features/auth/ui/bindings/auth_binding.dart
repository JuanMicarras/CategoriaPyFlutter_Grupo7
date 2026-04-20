import 'package:get/get.dart';
import '../viewmodels/auth_controller.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/remote/i_authentication_source.dart';
import '../../data/datasources/remote/authentication_source_service.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Inyectamos la conexión a la API
    Get.lazyPut<IAuthenticationSource>(() => AuthenticationSourceService());

    // 2. Inyectamos el Repositorio pasándole la API con Get.find()
    Get.lazyPut<IAuthRepository>(() => AuthRepositoryImpl(Get.find()));

    // 3. Inyectamos el Controlador pasándole el Repositorio
    Get.lazyPut(() => AuthController(repository: Get.find()));
  }
}