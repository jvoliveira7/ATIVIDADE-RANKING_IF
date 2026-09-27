import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../data/repositories/i_preference_repository.dart';
import 'i_preference_usecases.dart';

/// Grava a preferência de tema (itens 14.15 e 22).
final class AlterarTemaUseCase implements IAlterarTemaUseCase {
  final IPreferenceRepository _repository;

  AlterarTemaUseCase({required IPreferenceRepository repository})
      : _repository = repository;

  @override
  Future<VoidResult> call(TemaParams params) async {
    await _repository.salvarTemaEscuro(params.escuro);
    return const Success(null);
  }
}

/// Lê a preferência de tema salva. Sem preferência gravada, assume tema claro.
final class CarregarTemaUseCase implements ICarregarTemaUseCase {
  final IPreferenceRepository _repository;

  CarregarTemaUseCase({required IPreferenceRepository repository})
      : _repository = repository;

  @override
  Future<BoolResult> call(NoParams params) async {
    final escuro = await _repository.lerTemaEscuro();
    return Success(escuro ?? false);
  }
}
