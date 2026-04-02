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
}