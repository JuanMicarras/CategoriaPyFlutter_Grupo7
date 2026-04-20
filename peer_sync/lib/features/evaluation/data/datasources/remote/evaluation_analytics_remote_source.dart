import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:peer_sync/features/evaluation/data/datasources/remote/i_evaluation_analytics_remote_source.dart';
import 'package:peer_sync/features/evaluation/domain/models/chart_point.dart';
import 'package:peer_sync/features/evaluation/domain/models/dashboard_metric.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EvaluationAnalyticsRemoteSource
    implements IEvaluationAnalyticsRemoteSource {
  final http.Client httpClient;
  final String dbUrl =
      'https://roble-api.openlab.uninorte.edu.co/database/peer_sync_2e18809588';

  EvaluationAnalyticsRemoteSource({http.Client? client})
    : httpClient = client ?? http.Client();

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenA');
    if (token == null) {
      throw Exception('No hay sesión activa.');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<dynamic>> _readTable(
    String tableName,
    Map<String, String> queryParams,
    Map<String, String> headers,
  ) async {
    final uri = Uri.parse(
      '$dbUrl/read',
    ).replace(queryParameters: {'tableName': tableName, ...queryParams});

    final res = await httpClient.get(uri, headers: headers);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data is List ? data : (data['data'] ?? data['records'] ?? []);
    }

    return [];
  }

  Future<String> _getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();

    const possibleKeys = [
      'email',
      'userEmail',
      'user_email',
      'currentEmail',
      'loggedEmail',
    ];

    for (final key in possibleKeys) {
      final value = prefs.getString(key);
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return '';
  }

  String _asString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  double _asDouble(dynamic value) {
    return double.tryParse(value.toString()) ?? 0.0;
  }

  bool _asBool(dynamic value) {
    if (value is bool) return value;
    final raw = value.toString().toLowerCase().trim();
    return raw == 'true' || raw == '1';
  }

  DateTime? _asDateTime(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString()).toLocal();
    } catch (_) {
      return null;
    }
  }

  String _shortActivityLabel(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Act';
    if (trimmed.length <= 10) return trimmed;
    return '${trimmed.substring(0, 10)}...';
  }

  String _criteriaShortLabel(String name) {
    final normalized = name.toLowerCase().trim();
    switch (normalized) {
      case 'puntualidad':
        return 'Punt.';
      case 'contribución':
      case 'contribucion':
        return 'Contrib.';
      case 'compromiso':
        return 'Comp.';
      case 'actitud':
        return 'Actitud';
      case 'general':
        return 'General';
      default:
        return name.length <= 10 ? name : '${name.substring(0, 10)}...';
    }
  }

  bool _isOpenActivity(Map<String, dynamic> activity) {
    final now = DateTime.now();
    final start = _asDateTime(activity['start_date']);
    final end = _asDateTime(activity['end_date']);
    if (start == null || end == null) return false;
    return !now.isBefore(start) && !now.isAfter(end);
  }

  bool _isVisibleActivity(Map<String, dynamic> activity) {
    return _asBool(activity['visibility']);
  }

  Future<List<dynamic>> _getAllActivities(Map<String, String> headers) async {
    return await _readTable('Activity', {}, headers);
  }

  Future<List<dynamic>> _getAllGroups(Map<String, String> headers) async {
    return await _readTable('Group', {}, headers);
  }

  Future<List<dynamic>> _getAllGroupMembers(Map<String, String> headers) async {
    return await _readTable('GroupMember', {}, headers);
  }

  Future<List<dynamic>> _getAllEvaluations(Map<String, String> headers) async {
    return await _readTable('Evaluation', {}, headers);
  }

  Future<List<dynamic>> _getAllCriteria(Map<String, String> headers) async {
    return await _readTable('Criteria', {}, headers);
  }

  Future<List<dynamic>> _getAllResultPerCriteria(
    Map<String, String> headers,
  ) async {
    return await _readTable('ResultPerCriteria', {}, headers);
  }

  Future<List<dynamic>> _getAllCategories(Map<String, String> headers) async {
    return await _readTable('Category', {}, headers);
  }

  Future<List<dynamic>> _getAllUsers(Map<String, String> headers) async {
    return await _readTable('Users', {}, headers);
  }

  Future<List<dynamic>> _getAllCourseMembers(
    Map<String, String> headers,
  ) async {
    return await _readTable('CourseMember', {}, headers);
  }

  Future<String> _getCurrentUserId(Map<String, String> headers) async {
    final email = await _getCurrentUserEmail();
    if (email.isEmpty) return '';

    final users = await _getAllUsers(headers);

    Map<String, dynamic>? match;
    for (final user in users) {
      final mappedUser = Map<String, dynamic>.from(user);
      if (_asString(mappedUser['email']) == email) {
        match = mappedUser;
        break;
      }
    }

    if (match == null) return '';

    // CourseMember.user_id se relaciona con Users.user_id
    return _asString(match['user_id']);
  }

  Future<List<Map<String, dynamic>>> _getStudentScopedActivities(
    String myEmail,
    Map<String, String> headers,
  ) async {
    final allActivities = await _getAllActivities(headers);
    final allGroups = await _getAllGroups(headers);
    final allGroupMembers = await _getAllGroupMembers(headers);

    final myGroupIds = allGroupMembers
        .map((m) => Map<String, dynamic>.from(m))
        .where((m) => _asString(m['email']) == myEmail)
        .map((m) => _asString(m['group_id']))
        .where((id) => id.isNotEmpty)
        .toSet();

    final myCategoryIds = allGroups
        .map((g) => Map<String, dynamic>.from(g))
        .where((g) => myGroupIds.contains(_asString(g['_id'])))
        .map((g) => _asString(g['category_id']))
        .where((id) => id.isNotEmpty)
        .toSet();

    return allActivities
        .map((a) => Map<String, dynamic>.from(a))
        .where(
          (a) =>
              myCategoryIds.contains(_asString(a['category_id'])) &&
              _isVisibleActivity(a),
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> _getTeacherScopedActivities(
    Map<String, String> headers,
  ) async {
    final currentUserId = await _getCurrentUserId(headers);

    final allActivities = await _getAllActivities(headers);
    final allCategories = await _getAllCategories(headers);
    final courseMembers = await _getAllCourseMembers(headers);

    if (currentUserId.isEmpty) {
      return [];
    }

    final teacherCourseIds = courseMembers
        .map((row) => Map<String, dynamic>.from(row))
        .where((row) => _asString(row['user_id']) == currentUserId)
        .map((row) => _asString(row['course_id']))
        .where((id) => id.isNotEmpty)
        .toSet();

    if (teacherCourseIds.isEmpty) {
      return [];
    }

    final teacherCategoryIds = allCategories
        .map((c) => Map<String, dynamic>.from(c))
        .where((c) => teacherCourseIds.contains(_asString(c['course_id'])))
        .map((c) => _asString(c['_id']))
        .where((id) => id.isNotEmpty)
        .toSet();

    return allActivities
        .map((a) => Map<String, dynamic>.from(a))
        .where(
          (a) =>
              teacherCategoryIds.contains(_asString(a['category_id'])) &&
              _isVisibleActivity(a),
        )
        .toList();
  }

  List<ChartPoint> _orderCriteriaChart(Map<String, double> valuesByName) {
    const preferredOrder = [
      'Puntualidad',
      'Contribución',
      'Contribucion',
      'Compromiso',
      'Actitud',
      'General',
    ];

    final ordered = <ChartPoint>[];

    for (final criteriaName in preferredOrder) {
      if (valuesByName.containsKey(criteriaName)) {
        ordered.add(
          ChartPoint(
            label: _criteriaShortLabel(criteriaName),
            value: valuesByName[criteriaName]!,
          ),
        );
      }
    }

    valuesByName.forEach((name, value) {
      final label = _criteriaShortLabel(name);
      final alreadyAdded = ordered.any((point) => point.label == label);
      if (!alreadyAdded) {
        ordered.add(ChartPoint(label: label, value: value));
      }
    });

    return ordered;
  }

  @override
  Future<List<ChartPoint>> getStudentHomeTrend(String myEmail) async {
    final headers = await _getHeaders();
    final scopedActivities = await _getStudentScopedActivities(
      myEmail,
      headers,
    );
    final allEvaluations = await _getAllEvaluations(headers);

    final activityMap = <String, Map<String, dynamic>>{
      for (final a in scopedActivities) _asString(a['_id']): a,
    };

    final groupedScores = <String, List<double>>{};

    for (final evalRaw in allEvaluations) {
      final eval = Map<String, dynamic>.from(evalRaw);
      final evaluatedId = _asString(eval['evaluated_id']);
      final activityId = _asString(eval['activity_id']);

      if (evaluatedId != myEmail) continue;
      if (!activityMap.containsKey(activityId)) continue;

      groupedScores
          .putIfAbsent(activityId, () => [])
          .add(_asDouble(eval['general_score']));
    }

    final points = groupedScores.entries.map((entry) {
      final activity = activityMap[entry.key]!;
      final avg =
          entry.value.fold(0.0, (a, b) => a + b) /
          entry.value.length.toDouble();

      return {
        'label': _shortActivityLabel(_asString(activity['name'])),
        'value': avg,
        'endDate': _asDateTime(activity['end_date']) ?? DateTime(1970),
      };
    }).toList();

    points.sort(
      (a, b) => (b['endDate'] as DateTime).compareTo(a['endDate'] as DateTime),
    );

    final recent = points.take(7).toList()
      ..sort(
        (a, b) =>
            (a['endDate'] as DateTime).compareTo(b['endDate'] as DateTime),
      );

    return recent
        .map(
          (p) => ChartPoint(
            label: p['label'] as String,
            value: p['value'] as double,
          ),
        )
        .toList();
  }

  @override
  Future<List<ChartPoint>> getStudentCategoryCriteriaAverages({
    required String categoryId,
    required String myEmail,
  }) async {
    final headers = await _getHeaders();

    final activities = await _readTable('Activity', {
      'category_id': categoryId,
    }, headers);

    final visibleActivities = activities
        .map((a) => Map<String, dynamic>.from(a))
        .where((a) => _isVisibleActivity(a))
        .toList();

    final activityIds = visibleActivities
        .map((a) => _asString(a['_id']))
        .where((id) => id.isNotEmpty)
        .toSet();

    final allEvaluations = await _getAllEvaluations(headers);
    final allDetails = await _getAllResultPerCriteria(headers);
    final allCriteria = await _getAllCriteria(headers);

    final criteriaNameById = <String, String>{
      for (final cRaw in allCriteria)
        _asString(Map<String, dynamic>.from(cRaw)['_id']): _asString(
          Map<String, dynamic>.from(cRaw)['name'],
        ),
    };

    final myEvaluations = allEvaluations
        .map((e) => Map<String, dynamic>.from(e))
        .where((e) {
          return _asString(e['evaluated_id']) == myEmail &&
              activityIds.contains(_asString(e['activity_id']));
        })
        .toList();

    if (myEvaluations.isEmpty) return [];

    final evaluationIds = myEvaluations
        .map((e) => _asString(e['_id']))
        .where((id) => id.isNotEmpty)
        .toSet();

    final criteriaBuckets = <String, List<double>>{};
    final generalScores = <double>[];

    for (final eval in myEvaluations) {
      generalScores.add(_asDouble(eval['general_score']));
    }

    for (final detailRaw in allDetails) {
      final detail = Map<String, dynamic>.from(detailRaw);
      final evaluationId = _asString(detail['evaluation_id']);
      if (!evaluationIds.contains(evaluationId)) continue;

      final criteriaId = _asString(detail['criteria_id']);
      final criteriaName = criteriaNameById[criteriaId];
      if (criteriaName == null || criteriaName.isEmpty) continue;

      criteriaBuckets
          .putIfAbsent(criteriaName, () => [])
          .add(_asDouble(detail['criteria_score']));
    }

    final averagesByName = <String, double>{};

    criteriaBuckets.forEach((name, scores) {
      final avg = scores.fold(0.0, (a, b) => a + b) / scores.length.toDouble();
      averagesByName[name] = avg;
    });

    if (generalScores.isNotEmpty) {
      averagesByName['General'] =
          generalScores.fold(0.0, (a, b) => a + b) / generalScores.length;
    }

    return _orderCriteriaChart(averagesByName);
  }

  @override
  Future<List<ChartPoint>> getTeacherHomeCompletionTrend() async {
    final headers = await _getHeaders();
    final activities = await _getTeacherScopedActivities(headers);

    final allGroups = (await _getAllGroups(
      headers,
    )).map((g) => Map<String, dynamic>.from(g)).toList();

    final allMembers = (await _getAllGroupMembers(
      headers,
    )).map((m) => Map<String, dynamic>.from(m)).toList();

    final allEvaluations = (await _getAllEvaluations(
      headers,
    )).map((e) => Map<String, dynamic>.from(e)).toList();

    final recentActivities = List<Map<String, dynamic>>.from(activities)
      ..sort((a, b) {
        final aEnd = _asDateTime(a['end_date']) ?? DateTime(1970);
        final bEnd = _asDateTime(b['end_date']) ?? DateTime(1970);
        return bEnd.compareTo(aEnd);
      });

    final selected = recentActivities.take(7).toList()
      ..sort((a, b) {
        final aEnd = _asDateTime(a['end_date']) ?? DateTime(1970);
        final bEnd = _asDateTime(b['end_date']) ?? DateTime(1970);
        return aEnd.compareTo(bEnd);
      });

    final points = <ChartPoint>[];

    for (final activity in selected) {
      final activityId = _asString(activity['_id']);
      final categoryId = _asString(activity['category_id']);

      final groups = allGroups
          .where((g) => _asString(g['category_id']) == categoryId)
          .toList();

      int expectedTotal = 0;
      int actualTotal = 0;

      for (final group in groups) {
        final groupId = _asString(group['_id']);
        final members = allMembers
            .where((m) => _asString(m['group_id']) == groupId)
            .toList();

        final groupSize = members.length;
        if (groupSize <= 1) continue;

        expectedTotal += groupSize * (groupSize - 1);

        actualTotal += allEvaluations.where((e) {
          return _asString(e['activity_id']) == activityId &&
              _asString(e['group_id']) == groupId;
        }).length;
      }

      final percentage = expectedTotal == 0
          ? 0.0
          : (actualTotal / expectedTotal) * 100.0;

      points.add(
        ChartPoint(
          label: _shortActivityLabel(_asString(activity['name'])),
          value: percentage.clamp(0.0, 100.0),
        ),
      );
    }

    return points;
  }

  @override
  Future<List<ChartPoint>> getTeacherCategoryCriteriaAverages({
    required String categoryId,
  }) async {
    final headers = await _getHeaders();

    final activities = await _readTable('Activity', {
      'category_id': categoryId,
    }, headers);

    final activityIds = activities
        .map((a) => Map<String, dynamic>.from(a))
        .map((a) => _asString(a['_id']))
        .where((id) => id.isNotEmpty)
        .toSet();

    final allEvaluations = (await _getAllEvaluations(
      headers,
    )).map((e) => Map<String, dynamic>.from(e)).toList();

    final allDetails = (await _getAllResultPerCriteria(
      headers,
    )).map((d) => Map<String, dynamic>.from(d)).toList();

    final allCriteria = (await _getAllCriteria(
      headers,
    )).map((c) => Map<String, dynamic>.from(c)).toList();

    final criteriaNameById = <String, String>{
      for (final c in allCriteria) _asString(c['_id']): _asString(c['name']),
    };

    final categoryEvaluations = allEvaluations.where((e) {
      return activityIds.contains(_asString(e['activity_id']));
    }).toList();

    if (categoryEvaluations.isEmpty) return [];

    final evaluationIds = categoryEvaluations
        .map((e) => _asString(e['_id']))
        .where((id) => id.isNotEmpty)
        .toSet();

    final criteriaBuckets = <String, List<double>>{};
    final generalScores = <double>[];

    for (final eval in categoryEvaluations) {
      generalScores.add(_asDouble(eval['general_score']));
    }

    for (final detail in allDetails) {
      final evaluationId = _asString(detail['evaluation_id']);
      if (!evaluationIds.contains(evaluationId)) continue;

      final criteriaId = _asString(detail['criteria_id']);
      final criteriaName = criteriaNameById[criteriaId];
      if (criteriaName == null || criteriaName.isEmpty) continue;

      criteriaBuckets
          .putIfAbsent(criteriaName, () => [])
          .add(_asDouble(detail['criteria_score']));
    }

    final averagesByName = <String, double>{};

    criteriaBuckets.forEach((name, scores) {
      averagesByName[name] =
          scores.fold(0.0, (a, b) => a + b) / scores.length.toDouble();
    });

    if (generalScores.isNotEmpty) {
      averagesByName['General'] =
          generalScores.fold(0.0, (a, b) => a + b) / generalScores.length;
    }

    return _orderCriteriaChart(averagesByName);
  }

  @override
  Future<DashboardMetric> getStudentAverageMetric(String myEmail) async {
    final headers = await _getHeaders();
    final scopedActivities = await _getStudentScopedActivities(
      myEmail,
      headers,
    );
    final scopedActivityIds = scopedActivities
        .map((a) => _asString(a['_id']))
        .where((id) => id.isNotEmpty)
        .toSet();

    final allEvaluations = (await _getAllEvaluations(
      headers,
    )).map((e) => Map<String, dynamic>.from(e)).toList();

    final myReceived = allEvaluations.where((e) {
      return _asString(e['evaluated_id']) == myEmail &&
          scopedActivityIds.contains(_asString(e['activity_id']));
    }).toList();

    if (myReceived.isEmpty) {
      return const DashboardMetric(title: 'Promedio general', value: '0.0');
    }

    final average =
        myReceived
            .map((e) => _asDouble(e['general_score']))
            .fold(0.0, (a, b) => a + b) /
        myReceived.length;

    return DashboardMetric(
      title: 'Promedio general',
      value: average.toStringAsFixed(1),
    );
  }

  @override
  Future<DashboardMetric> getStudentPendingMetric(String myEmail) async {
    final headers = await _getHeaders();
    final scopedActivities = await _getStudentScopedActivities(
      myEmail,
      headers,
    );

    final allEvaluations = (await _getAllEvaluations(
      headers,
    )).map((e) => Map<String, dynamic>.from(e)).toList();

    int pending = 0;

    for (final activity in scopedActivities) {
      if (!_isOpenActivity(activity)) continue;

      final activityId = _asString(activity['_id']);

      final alreadyEvaluated = allEvaluations.any((e) {
        return _asString(e['activity_id']) == activityId &&
            _asString(e['evaluator_id']) == myEmail;
      });

      if (!alreadyEvaluated) {
        pending++;
      }
    }

    return DashboardMetric(title: 'Pendientes', value: pending.toString());
  }

  @override
  Future<DashboardMetric> getTeacherActiveActivitiesMetric() async {
    final headers = await _getHeaders();
    final activities = await _getTeacherScopedActivities(headers);

    final activeCount = activities.where((a) => _isOpenActivity(a)).length;

    return DashboardMetric(title: 'Activas', value: activeCount.toString());
  }

  @override
  Future<DashboardMetric> getTeacherPendingGroupsMetric() async {
    final headers = await _getHeaders();
    final activities = await _getTeacherScopedActivities(headers);
    final activeActivities = activities
        .where((a) => _isOpenActivity(a))
        .toList();

    final allGroups = (await _getAllGroups(
      headers,
    )).map((g) => Map<String, dynamic>.from(g)).toList();

    final allMembers = (await _getAllGroupMembers(
      headers,
    )).map((m) => Map<String, dynamic>.from(m)).toList();

    final allEvaluations = (await _getAllEvaluations(
      headers,
    )).map((e) => Map<String, dynamic>.from(e)).toList();

    int pendingGroups = 0;

    for (final activity in activeActivities) {
      final activityId = _asString(activity['_id']);
      final categoryId = _asString(activity['category_id']);

      final groups = allGroups
          .where((g) => _asString(g['category_id']) == categoryId)
          .toList();

      for (final group in groups) {
        final groupId = _asString(group['_id']);
        final members = allMembers
            .where((m) => _asString(m['group_id']) == groupId)
            .toList();

        final groupSize = members.length;
        final expected = groupSize <= 1 ? 0 : groupSize * (groupSize - 1);

        final actual = allEvaluations.where((e) {
          return _asString(e['activity_id']) == activityId &&
              _asString(e['group_id']) == groupId;
        }).length;

        if (expected > 0 && actual < expected) {
          pendingGroups++;
        }
      }
    }

    return DashboardMetric(
      title: 'Grupos pendientes',
      value: pendingGroups.toString(),
    );
  }
}
