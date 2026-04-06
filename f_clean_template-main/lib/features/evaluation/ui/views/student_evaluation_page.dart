import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/utils/student_navigation_helpers.dart';
import 'package:peer_sync/core/widgets/evaluation_card.dart';
import 'package:peer_sync/core/widgets/navbar.dart';
import 'package:peer_sync/core/widgets/peer_evaluation.dart';
import '../viewmodels/evaluation_form_controller.dart';

class StudentEvaluationPage extends StatefulWidget {
  final String activityId;
  final String activityName;
  final String categoryId;
  final bool isExpired;

  const StudentEvaluationPage({
    super.key,
    required this.activityId,
    required this.activityName,
    required this.categoryId,
    this.isExpired = false,
  });

  @override
  State<StudentEvaluationPage> createState() => _StudentEvaluationPageState();
}

class _StudentEvaluationPageState extends State<StudentEvaluationPage> {
  final EvaluationFormController controller = Get.put(
    EvaluationFormController(Get.find()),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadFormData(widget.activityId, widget.categoryId);
    });
  }

  String toTitleCase(String text) {
    return text
        .toLowerCase()
        .split(' ')
        .where((word) => word.trim().isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        title: Text(
          widget.activityName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final myPeerData = controller.peers.firstWhereOrNull(
          (p) => p.email == controller.myEmail,
        );
        final otherPeers = controller.peers
            .where((p) => p.email != controller.myEmail)
            .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Mis resultados",
                style: AppTheme.h3.copyWith(
                  color: AppTheme.textColor,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 16),

              if (myPeerData != null) ...[
                Builder(
                  builder: (context) {
                    String getMyScoreText(String criteriaName) {
                      if (controller.myAverageResults.isEmpty) return "0.0";

                      final normalizedTarget = criteriaName
                          .toLowerCase()
                          .replaceAll('ó', 'o');

                      final matchedCriteria = controller.criteriaList
                          .firstWhereOrNull((c) {
                            return c.name.toLowerCase().replaceAll('ó', 'o') ==
                                normalizedTarget;
                          });

                      if (matchedCriteria != null &&
                          controller.myAverageResults.containsKey(
                            matchedCriteria.id,
                          )) {
                        return controller.myAverageResults[matchedCriteria.id]!
                            .toStringAsFixed(1);
                      }
                      return "0.0";
                    }

                    final myGeneralScore =
                        controller.myAverageResults['general_score']
                            ?.toStringAsFixed(1) ??
                        "0.0";

                    return PeerEvaluationCard(
                      width: double.infinity,
                      studentName: toTitleCase(
                        "${myPeerData.firstName} ${myPeerData.lastName}",
                      ),
                      progressText: controller.myAverageResults.isEmpty
                          ? "Aún no te han evaluado"
                          : "Promedio actual",
                      initiallyExpanded: false,
                      puntualidad: PeerEvaluationData(
                        subtitle: "Promedio",
                        score: getMyScoreText("Puntualidad"),
                      ),
                      contribucion: PeerEvaluationData(
                        subtitle: "Promedio",
                        score: getMyScoreText("Contribución"),
                      ),
                      compromiso: PeerEvaluationData(
                        subtitle: "Promedio",
                        score: getMyScoreText("Compromiso"),
                      ),
                      actitud: PeerEvaluationData(
                        subtitle: "Promedio",
                        score: getMyScoreText("Actitud"),
                      ),
                      general: PeerEvaluationData(
                        subtitle: "Nota Final",
                        score: myGeneralScore,
                      ),
                    );
                  },
                ),
              ],

              const SizedBox(height: 35),

              Text(
                "Evaluaciones",
                style: AppTheme.h3.copyWith(
                  color: AppTheme.textColor,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 16),

              if (otherPeers.isEmpty)
                const Text("No hay más compañeros en tu grupo para evaluar."),

              ...otherPeers.map((peer) {
                final isAlreadyEvaluated = controller.completedEvaluations
                    .containsKey(peer.email);
                final savedScores = isAlreadyEvaluated
                    ? controller.completedEvaluations[peer.email]!
                    : <String, double>{};
                final isReadOnly = isAlreadyEvaluated || widget.isExpired;

                double? getSavedScore(String criteriaName) {
                  if (!isAlreadyEvaluated) return null;
                  final criteriaObj = controller.criteriaList.firstWhereOrNull(
                    (c) => c.name == criteriaName,
                  );
                  return criteriaObj != null
                      ? savedScores[criteriaObj.id]
                      : null;
                }

                String progressTextStr;
                if (isAlreadyEvaluated) {
                  progressTextStr = "Completado";
                } else if (widget.isExpired) {
                  progressTextStr = "No evaluado";
                } else {
                  progressTextStr = "Pendiente";
                }

                final isThisPeerSubmitting = controller.isPeerSubmitting(
                  peer.email,
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    children: [
                      EditablePeerEvaluationCard(
                        width: double.infinity,
                        studentName: toTitleCase(
                          "${peer.firstName} ${peer.lastName}",
                        ),
                        progressText: progressTextStr,
                        initiallyExpanded: false,
                        initialPuntualidad: getSavedScore("Puntualidad"),
                        initialContribucion: getSavedScore("Contribución"),
                        initialCompromiso: getSavedScore("Compromiso"),
                        initialActitud: getSavedScore("Actitud"),
                        onScoresChanged: (scores) {
                          if (!isAlreadyEvaluated) {
                            controller.updateScoreForPeer(peer.email, scores);
                          } else {
                            Get.snackbar(
                              'Aviso',
                              'Ya calificaste a este compañero. Las notas son de solo lectura.',
                              backgroundColor: Colors.blue,
                              colorText: Colors.white,
                            );
                          }
                        },
                      ),

                      if (!isReadOnly)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: isThisPeerSubmitting
                                  ? null
                                  : () => controller.submitEvaluationForPeer(
                                      widget.activityId,
                                      widget.categoryId,
                                      peer.email,
                                    ),
                              icon: isThisPeerSubmitting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.save_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                              label: Text(
                                isThisPeerSubmitting
                                    ? "Guardando..."
                                    : "Guardar evaluación",
                                style: AppTheme.buttonM.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor200,
                                disabledBackgroundColor: AppTheme.grayColor100
                                    .withOpacity(0.65),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 40),
            ],
          ),
        );
      }),
      bottomNavigationBar: NavBar(
        currentIndex: 0,
        onTap: (index) => StudentNavigationHelpers.handleNavTap(index),
      ),
    );
  }
}
