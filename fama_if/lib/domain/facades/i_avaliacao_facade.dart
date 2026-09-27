import '../../core/typedefs/types_defs.dart';

/// Agrupa os use cases de avaliação (item 4.4).
abstract interface class IAvaliacaoFacade {
  Future<AvaliacaoResult> avaliar(AvaliarParams params);
  Future<AvaliacaoResult> alterarAvaliacao(AvaliarParams params);
  Future<AvaliacaoResult> consultarAvaliacao(IdParams params);
  Future<ListAvaliacaoResult> carregarAvaliacoes(NoParams params);
  Future<BoolResult> verificarAutoavaliacao(IdParams params);
}
