import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import '../viewmodels/evaluation_form_controller.dart';

// Importamos los widgets de tu compañera (Ajusta las rutas si están en otra carpeta)
import 'package:peer_sync/core/widgets/evaluation_card.dart';
import 'package:peer_sync/core/widgets/peer_evaluation.dart';

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

        // Filtramos quién soy yo y quiénes son mis compañeros
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
              // ==========================================
              // SECCIÓN: MIS RESULTADOS (Solo lectura)
              // ==========================================
              Text("Mis resultados", style: AppTheme.h3.copyWith(color: AppTheme.textColor, fontSize: 20)),
              const SizedBox(height: 16),
              
              if (myPeerData != null) ...[
                Builder(
                  builder: (context) {
                    // Función para extraer la nota por nombre (A prueba de tildes)
                    String getMyScoreText(String criteriaName) {
                      if (controller.myAverageResults.isEmpty) return "0.0";
                      
                      final normalizedTarget = criteriaName.toLowerCase().replaceAll('ó', 'o');
                      final matchedCriteria = controller.criteriaList.firstWhereOrNull((c) {
                        return c.name.toLowerCase().replaceAll('ó', 'o') == normalizedTarget;
                      });
                      
                      if (matchedCriteria != null && controller.myAverageResults.containsKey(matchedCriteria.id)) {
                        return controller.myAverageResults[matchedCriteria.id]!.toStringAsFixed(1);
                      }
                      return "0.0";
                    }

                    // Extraemos la nota general y calculamos el porcentaje para la barra (sobre 5.0)
                    final myGeneralScore = controller.myAverageResults['general_score']?.toStringAsFixed(1) ?? "0.0";
                    final myGeneralProgress = (double.tryParse(myGeneralScore) ?? 0.0) / 5.0;

                    return PeerEvaluationCard(
                      width: double.infinity,
                      studentName: "${myPeerData.firstName} ${myPeerData.lastName}",
                      progressText: controller.myAverageResults.isEmpty ? "Aún no te han evaluado" : "Promedio actual",
                      progress: myGeneralProgress, // Barra dinámica
                      initiallyExpanded: false,
                      puntualidad: PeerEvaluationData(subtitle: "Promedio", score: getMyScoreText("Puntualidad")),
                      contribucion: PeerEvaluationData(subtitle: "Promedio", score: getMyScoreText("Contribución")),
                      compromiso: PeerEvaluationData(subtitle: "Promedio", score: getMyScoreText("Compromiso")),
                      actitud: PeerEvaluationData(subtitle: "Promedio", score: getMyScoreText("Actitud")),
                      general: PeerEvaluationData(subtitle: "Nota Final", score: myGeneralScore),
                    );
                  }
                )
              ],
              const SizedBox(height: 35),

              // ==========================================
              // SECCIÓN: EVALUACIONES A COMPAÑEROS
              // ==========================================
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

              // Iteramos sobre el resto de compañeros usando el widget Editable
              ...otherPeers.map((peer) {
                // Verificamos si este compañero ya fue evaluado en la BD
                final isAlreadyEvaluated = controller.completedEvaluations
                    .containsKey(peer.email);
                final savedScores = isAlreadyEvaluated
                    ? controller.completedEvaluations[peer.email]!
                    : <String, double>{};
                final isReadOnly = isAlreadyEvaluated || widget.isExpired;
                // Función auxiliar para extraer la nota guardada por nombre del criterio
                double? getSavedScore(String criteriaName) {
                  if (!isAlreadyEvaluated) return null;
                  final criteriaObj = controller.criteriaList.firstWhereOrNull(
                    (c) => c.name == criteriaName,
                  );
                  return criteriaObj != null
                      ? savedScores[criteriaObj.id]
                      : null;
                }
                // Definimos los textos visuales
                String progressTextStr;
                if (isAlreadyEvaluated) {
                  progressTextStr = "Evaluación Completada";
                } else if (widget.isExpired) {
                  progressTextStr = "No evaluado (Actividad Cerrada)";
                } else {
                  progressTextStr = "Pendiente por evaluar";
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      EditablePeerEvaluationCard(
                        width: double.infinity,
                        studentName: "${peer.firstName} ${peer.lastName}",
                        progressText: progressTextStr,
                        progress: isAlreadyEvaluated ? 1.0 : 0.0,
                        initiallyExpanded: false,
                        
                        // Cargamos los datos históricos (si existen)
                        initialPuntualidad: getSavedScore("Puntualidad"),
                        initialContribucion: getSavedScore("Contribución"),
                        initialCompromiso: getSavedScore("Compromiso"),
                        initialActitud: getSavedScore("Actitud"),

                        onScoresChanged: (scores) {
                          // Solo permitimos actualizar si no ha sido evaluado
                          if (!isAlreadyEvaluated) {
                            controller.updateScoreForPeer(peer.email, scores);
                          } else {
                            Get.snackbar('Aviso', 'Ya calificaste a este compañero. Las notas son de solo lectura.', 
                                backgroundColor: Colors.blue, colorText: Colors.white);
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      
                      // Ocultamos el botón de Guardar si ya lo evaluamos
                      if (!isReadOnly)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: controller.isSubmitting.value 
                              ? null 
                              : () => controller.submitEvaluationForPeer(widget.activityId, widget.categoryId, peer.email),
                            icon: const Icon(Icons.save_rounded, color: AppTheme.primaryColor, size: 18),
                            label: const Text("Guardar Evaluación", style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                            style: TextButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                            ),
                          ),
                        )
                    ],
                  ),
                );
              }).toList(),

              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }
}
