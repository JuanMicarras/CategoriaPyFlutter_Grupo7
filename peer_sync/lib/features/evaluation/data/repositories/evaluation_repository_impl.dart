import 'package:peer_sync/features/evaluation/domain/models/activity.dart';
import 'package:peer_sync/features/evaluation/domain/models/activity_report.dart';
import 'package:peer_sync/features/evaluation/domain/models/criteria.dart';
import 'package:peer_sync/features/evaluation/domain/models/peer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../domain/repositories/i_evaluation_repository.dart';
import '../datasources/remote/i_evaluation_remote_source.dart';

class EvaluationRepositoryImpl implements IEvaluationRepository {
  final IEvaluationRemoteSource _remoteSource;

  // Inyectamos el Data Source
  EvaluationRepositoryImpl(this._remoteSource);

  @override
  Future<void> createActivity({
    required String categoryId,
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required bool visibility,
  }) async {
    // Llamamos al método que se conecta a la API de ROBLE
    await _remoteSource.createActivity(
      categoryId,
      name,
      description,
      startDate,
      endDate,
      visibility,
    );
  }

  @override
  Future<List<Activity>> getActivitiesByCategory(String categoryId) async {
    final prefs = await SharedPreferences.getInstance();

    /// 🔥 clave única por categoría
    final cacheKey = 'activities_$categoryId';
    final cacheTimeKey = 'activities_time_$categoryId';

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
        print("⚡ USANDO CACHE (activities)");

        return decoded.map<Activity>((json) {
          return Activity(
            id: json['_id'].toString(),
            categoryId: json['category_id'].toString(),
            name: json['name'].toString(),
            description: json['description']?.toString(),
            startDate: DateTime.parse(json['start_date']).toLocal(),
            endDate: DateTime.parse(json['end_date']).toLocal(),
            visibility: json['visibility'] ?? false,
          );
        }).toList();
      }

      /// 🟡 CACHE VIEJA → usar + refrescar
      print("🟡 CACHE VIEJA → REFRESH EN BACKGROUND");

      _refreshActivitiesInBackground(categoryId, cacheKey, cacheTimeKey);

      return decoded.map<Activity>((json) {
        return Activity(
          id: json['_id'].toString(),
          categoryId: json['category_id'].toString(),
          name: json['name'].toString(),
          description: json['description']?.toString(),
          startDate: DateTime.parse(json['start_date']).toLocal(),
          endDate: DateTime.parse(json['end_date']).toLocal(),
          visibility: json['visibility'] ?? false,
        );
      }).toList();
    }

    /// 🌐 NO HAY CACHE → API
    print("🌐 GET ACTIVITIES BY CATEGORY → API");

    final rawData = await _remoteSource.getActivitiesByCategory(categoryId);

    /// 💾 GUARDAR CACHE
    await prefs.setString(cacheKey, jsonEncode(rawData));
    await prefs.setInt(cacheTimeKey, now);

    print("💾 CACHE SAVED ($cacheKey)");

    return rawData.map<Activity>((json) {
      return Activity(
        id: json['_id'].toString(),
        categoryId: json['category_id'].toString(),
        name: json['name'].toString(),
        description: json['description']?.toString(),
        startDate: DateTime.parse(json['start_date']).toLocal(),
        endDate: DateTime.parse(json['end_date']).toLocal(),
        visibility: json['visibility'] ?? false,
      );
    }).toList();
  }

  void _refreshActivitiesInBackground(
    String categoryId,
    String cacheKey,
    String cacheTimeKey,
  ) async {
    try {
      print("🔄 REFRESH ACTIVITIES EN BACKGROUND");

      final data = await _remoteSource.getActivitiesByCategory(categoryId);

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(cacheKey, jsonEncode(data));
      await prefs.setInt(cacheTimeKey, DateTime.now().millisecondsSinceEpoch);

      print("✅ CACHE ACTUALIZADA (activities)");
    } catch (e) {
      print("⚠️ ERROR REFRESH ACTIVITIES: $e");
    }
  }

  @override
  Future<List<Peer>> getPeers(String categoryId, String studentEmail) async {
    final data = await _remoteSource.getPeers(categoryId, studentEmail);
    return data
        .map(
          (j) => Peer(
            email: j['email'].toString(),
            firstName: j['first_name'].toString(),
            lastName: j['last_name'].toString(),
          ),
        )
        .toList();
  }

  @override
  Future<List<Criteria>> getCriteria(String activityId) async {
    final data = await _remoteSource.getCriteria(activityId);
    return data
        .map(
          (j) => Criteria(
            id: j['_id'].toString(),
            activityId: j['activity_id'].toString(),
            name: j['name'].toString(),
            description: j['description']?.toString(),
            maxScore: double.tryParse(j['max_score'].toString()) ?? 5.0,
          ),
        )
        .toList();
  }

  @override
  Future<Map<String, Map<String, double>>> getMyEvaluations(
    String activityId,
    String myEmail,
  ) async {
    return await _remoteSource.getMyEvaluations(activityId, myEmail);
  }

  @override
  Future<void> submitEvaluation(
    String activityId,
    String categoryId,
    String evaluatorEmail,
    String evaluatedEmail,
    String comments,
    Map<String, double> scores,
  ) async {
    await _remoteSource.submitEvaluation(
      activityId,
      categoryId,
      evaluatorEmail,
      evaluatedEmail,
      comments,
      scores,
    );
  }

  @override
  Future<Map<String, double>> getMyAverageResults(
    String activityId,
    String myEmail,
  ) async {
    // Simplemente le pasa la pelota al Data Source
    return await _remoteSource.getMyAverageResults(activityId, myEmail);
  }

  @override
  Future<List<GroupReport>> getActivityReport(
    String activityId,
    String categoryId,
  ) async {
    return await _remoteSource.getActivityReport(activityId, categoryId);
  }
}
