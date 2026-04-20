import '../../domain/models/category.dart';
import '../../domain/repositories/i_category_repository.dart';
import '../datasources/remote/i_category_remote_source.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peer_sync/features/auth/domain/repositories/i_auth_repository.dart';
import 'dart:convert';


class CategoryRepositoryImpl implements ICategoryRepository {
  final ICategoryRemoteSource remote;
  final IAuthRepository _authRepository;

  CategoryRepositoryImpl(this.remote, this._authRepository);

  @override
  Future<List<Category>> getCategoriesByCourse(String courseId) async {
    final data = await remote.getCategoriesByCourse(courseId);

    return data
        .map(
          (e) =>
              Category(id: e["id"], name: e["name"], courseId: e["course_id"]),
        )
        .toList();
  }

  @override
  Future<List<Category>> getCategoriesByStudent(String courseId) async {
    final prefs = await SharedPreferences.getInstance();

    final userEmail = await _authRepository.getCurrentUserEmail();

    if (userEmail == null) {
      print("❌ No hay usuario logueado");
      return [];
    }

    /// 🔥 clave única (usuario + curso)
    final cacheKey = 'categories_${userEmail}_$courseId';
    final cacheTimeKey = 'categories_time_${userEmail}_$courseId';

    final cached = prefs.getString(cacheKey);
    final cacheTime = prefs.getInt(cacheTimeKey);

    final now = DateTime.now().millisecondsSinceEpoch;

    /// ⏱ 5 minutos
    const cacheDuration = 5 * 60 * 1000;

    /// 🔥 SI HAY CACHE
    if (cached != null && cacheTime != null) {
      final isFresh = (now - cacheTime) < cacheDuration;

      print("📦 CACHE encontrada ($cacheKey)");
      print("⏱ Cache fresca: $isFresh");

      final List decoded = jsonDecode(cached);

      /// ⚡ CACHE FRESCA
      if (isFresh) {
        print("⚡ USANDO CACHE (categories)");

        return decoded.map<Category>((e) {
          return Category(
            id: e["id"],
            name: e["name"],
            courseId: e["course_id"],
          );
        }).toList();
      }

      /// 🟡 CACHE VIEJA → usar + refresh
      print("🟡 CACHE VIEJA → REFRESH EN BACKGROUND");

      _refreshCategoriesInBackground(
        userEmail,
        courseId,
        cacheKey,
        cacheTimeKey,
      );

      return decoded.map<Category>((e) {
        return Category(id: e["id"], name: e["name"], courseId: e["course_id"]);
      }).toList();
    }

    /// 🌐 NO HAY CACHE → API
    print("🌐 GET CATEGORIES BY STUDENT → API");

    final data = await remote.getCategoriesByStudent(courseId);

    /// 💾 GUARDAR CACHE
    await prefs.setString(cacheKey, jsonEncode(data));
    await prefs.setInt(cacheTimeKey, now);

    print("💾 CACHE SAVED ($cacheKey)");

    return data.map<Category>((e) {
      return Category(id: e["id"], name: e["name"], courseId: e["course_id"]);
    }).toList();
  }

  void _refreshCategoriesInBackground(
    String userEmail,
    String courseId,
    String cacheKey,
    String cacheTimeKey,
  ) async {
    try {
      print("🔄 REFRESH CATEGORIES EN BACKGROUND");

      final data = await remote.getCategoriesByStudent(courseId);

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(cacheKey, jsonEncode(data));
      await prefs.setInt(cacheTimeKey, DateTime.now().millisecondsSinceEpoch);

      print("✅ CACHE ACTUALIZADA (categories)");
    } catch (e) {
      print("⚠️ ERROR REFRESH CATEGORIES: $e");
    }
  }
}
