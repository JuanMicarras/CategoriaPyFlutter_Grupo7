import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/repositories/i_evaluation_repository.dart';
import '../../domain/models/peer.dart';
import '../../domain/models/criteria.dart';
import '../../../auth/ui/viewmodels/auth_controller.dart';

class EvaluationFormController extends GetxController {
  final IEvaluationRepository repository;
  final AuthController authController = Get.find();

  final isLoading = false.obs;

  // Estado de guardado por compañero
  final submittingPeers = <String, bool>{}.obs;

  final peers = <Peer>[].obs;
  final criteriaList = <Criteria>[].obs;

  // Mapa para almacenar las notas temporales que el usuario le da a cada compañero
  // Formato: { "email_del_compañero": { "Puntualidad": 4.5, "Actitud": 5.0 } }
  final pendingEvaluations = <String, Map<String, double>>{}.obs;
  final completedEvaluations = <String, Map<String, double>>{}.obs;

  final myAverageResults = <String, double>{}.obs;

  EvaluationFormController(this.repository);

  // Saber quién soy yo
  String get myEmail => authController.user?.email ?? '';
  Peer? get myPeerData => peers.firstWhereOrNull((p) => p.email == myEmail);
  List<Peer> get otherPeers => peers.where((p) => p.email != myEmail).toList();
  // 3. Formateador de texto (Title Case)
  String formatName(String firstName, String lastName) {
    final text = "$firstName $lastName";
    return text
        .toLowerCase()
        .split(' ')
        .where((word) => word.trim().isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  // 4. Obtener mi nota para un criterio específico
  String getMyScoreText(String criteriaName) {
    if (myAverageResults.isEmpty) return "0.0";

    final normalizedTarget = criteriaName.toLowerCase().replaceAll('ó', 'o');
    final matchedCriteria = criteriaList.firstWhereOrNull((c) {
      return c.name.toLowerCase().replaceAll('ó', 'o') == normalizedTarget;
    });

    if (matchedCriteria != null &&
        myAverageResults.containsKey(matchedCriteria.id)) {
      return myAverageResults[matchedCriteria.id]!.toStringAsFixed(1);
    }
    return "0.0";
  }

  // 5. Obtener mi nota general
  String get myGeneralScore {
    return myAverageResults['general_score']?.toStringAsFixed(1) ?? "0.0";
  }

  // 6. Obtener la nota que yo le guardé a un compañero
  double? getSavedScoreForPeer(String peerEmail, String criteriaName) {
    if (!completedEvaluations.containsKey(peerEmail)) return null;

    final savedScores = completedEvaluations[peerEmail]!;
    final criteriaObj = criteriaList.firstWhereOrNull(
      (c) => c.name == criteriaName,
    );

    return criteriaObj != null ? savedScores[criteriaObj.id] : null;
  }

  // 7. Calcular el estado de la evaluación para mostrar en UI
  String getEvaluationStatusText(String peerEmail, bool isExpired) {
    if (completedEvaluations.containsKey(peerEmail)) return "Completado";
    if (isExpired) return "No evaluado";
    return "Pendiente";
  }

  bool isPeerSubmitting(String peerEmail) {
    return submittingPeers[peerEmail] ?? false;
  }

  Future<void> loadFormData(String activityId, String categoryId) async {
    try {
      isLoading.value = true;

      final results = await Future.wait<dynamic>([
        repository.getPeers(categoryId, myEmail),
        repository.getCriteria(activityId),
        repository.getMyEvaluations(activityId, myEmail),
        repository.getMyAverageResults(activityId, myEmail),
      ]);

      peers.assignAll(results[0] as List<Peer>);
      criteriaList.assignAll(results[1] as List<Criteria>);
      completedEvaluations.value =
          results[2] as Map<String, Map<String, double>>;

      myAverageResults.value = results[3] as Map<String, double>;
    } catch (e) {
      _showError('No se pudieron cargar los datos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Se llama cada vez que cambia un dropdown de la rúbrica
  void updateScoreForPeer(String peerEmail, Map<String, double?> newScores) {
    if (!pendingEvaluations.containsKey(peerEmail)) {
      pendingEvaluations[peerEmail] = {};
    }

    newScores.forEach((key, value) {
      if (value != null) {
        String criteriaName = '';
        if (key == 'puntualidad') criteriaName = 'Puntualidad';
        if (key == 'contribucion') criteriaName = 'Contribución';
        if (key == 'compromiso') criteriaName = 'Compromiso';
        if (key == 'actitud') criteriaName = 'Actitud';

        if (criteriaName.isNotEmpty) {
          pendingEvaluations[peerEmail]![criteriaName] = value;
        }
      }
    });

    pendingEvaluations.refresh();
  }

  // Enviar la evaluación de un compañero específico a ROBLE
  Future<void> submitEvaluationForPeer(
    String activityId,
    String categoryId,
    String evaluatedEmail,
  ) async {
    final scoresToSubmit = pendingEvaluations[evaluatedEmail];

    if (scoresToSubmit == null || scoresToSubmit.length < 4) {
      _showError('Por favor, califica todos los criterios antes de guardar.');
      return;
    }

    try {
      submittingPeers[evaluatedEmail] = true;
      submittingPeers.refresh();

      // Transformamos los nombres legibles a los ID reales de la tabla Criteria
      Map<String, double> dbScores = {};

      scoresToSubmit.forEach((uiName, score) {
        final normalizedUiName = uiName.toLowerCase().replaceAll('ó', 'o');

        final matchedCriteria = criteriaList.firstWhereOrNull((c) {
          final normalizedDbName = c.name.toLowerCase().replaceAll('ó', 'o');
          return normalizedDbName == normalizedUiName;
        });

        if (matchedCriteria != null) {
          dbScores[matchedCriteria.id] = score;
        } else {
          print(
            "🔴 ALERTA: No se encontró el criterio '$uiName' en la base de datos.",
          );
        }
      });

      if (dbScores.isEmpty) {
        _showError(
          'Error interno: Los criterios de la app no coinciden con los de la Base de Datos.',
        );
        return;
      }

      await repository.submitEvaluation(
        activityId,
        categoryId,
        myEmail,
        evaluatedEmail,
        "",
        dbScores,
      );

      _showSuccess('Evaluación guardada exitosamente.');
      pendingEvaluations.remove(evaluatedEmail);
      pendingEvaluations.refresh();

      final updatedEvaluations = await repository.getMyEvaluations(
        activityId,
        myEmail,
      );
      completedEvaluations.value = updatedEvaluations;
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      submittingPeers[evaluatedEmail] = false;
      submittingPeers.refresh();
    }
  }

  void _showError(String message) {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(
              color: Theme.of(Get.context!).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
            ),
          ),
          backgroundColor: Theme.of(Get.context!).brightness == Brightness.light
              ? Color(0xFFD1B3FF)
              : Color(0xFF3A3260),
        ),
      );
    }
  }

  void _showSuccess(String message) {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(
              color: Theme.of(Get.context!).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
            ),
          ),
          backgroundColor: Theme.of(Get.context!).brightness == Brightness.light
              ? Color(0xFFD1B3FF)
              : Color(0xFF3A3260),
        ),
      );
    }
  }
}
