import 'package:peer_sync/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:get/get.dart';
import '../viewmodels/auth_controller.dart';
import '../../data/repositories/auth_repository_impl.dart'; 

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Inyectamos la implementación del Repositorio
    // (Asegúrate de haber creado AuthRepositoryImpl en data)
    Get.lazyPut<IAuthRepository>(() => AuthRepositoryImpl());

    // 2. Inyectamos el Controlador
    Get.lazyPut(() => AuthController(repository: Get.find()));
  }
}