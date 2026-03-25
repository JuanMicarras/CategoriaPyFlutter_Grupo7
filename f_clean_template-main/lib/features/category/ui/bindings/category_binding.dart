import 'package:get/get.dart';
import '../../domain/repositories/i_category_repository.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/datasources/remote/category_remote_source_service.dart';
import '../../data/datasources/remote/i_category_remote_source.dart';
import '../viewmodels/category_controller.dart';
import '../../../auth/ui/viewmodels/auth_controller.dart';

class CategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ICategoryRemoteSource>(() {
      final auth = Get.find<AuthController>();
      return CategoryRemoteSourceService(token: auth.user!.tokenA);
    });

    Get.lazyPut<ICategoryRepository>(
      () => CategoryRepositoryImpl(Get.find()),
    );

    Get.lazyPut(
      () => CategoryController(repository: Get.find()),
    );
  }
}