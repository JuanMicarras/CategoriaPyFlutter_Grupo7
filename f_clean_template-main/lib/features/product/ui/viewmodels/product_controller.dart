import 'package:peer_sync/features/product/domain/repositories/i_product_repository.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../domain/models/product.dart';

class ProductController extends GetxController {
  final RxList<Product> _products = <Product>[].obs;
  late IProductRepository repository;
  final RxBool isLoading = false.obs;
  List<Product> get products => _products;

  @override
  void onInit() {
    getProducts();
    super.onInit();
  }

  ProductController(this.repository);

  Future<void> getProducts() async {
    logInfo("ProductController: Getting products");
    isLoading.value = true;
    _products.value = await repository.getProducts();
    isLoading.value = false;
  }

  Future<void> addProduct(String name, String desc, String quantity) async {
    logInfo("ProductController: Add product");
    await repository.addProduct(
      Product(name: name, description: desc, quantity: int.parse(quantity)),
    );
    await getProducts();
  }

  Future<void> updateProduct(Product product) async {
    logInfo("ProductController: Update product");
    await repository.updateProduct(product);
    await getProducts();
  }

  Future<void> deleteProduct(Product p) async {
    logInfo("ProductController: Delete product");
    await repository.deleteProduct(p);
    await getProducts();
  }

  Future<void> deleteProducts() async {
    logInfo("ProductController: Delete all products");
    isLoading.value = true;
    await repository.deleteProducts();
    await getProducts();
    isLoading.value = false;
  }
}
