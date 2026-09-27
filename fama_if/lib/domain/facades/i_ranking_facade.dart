import '../../core/typedefs/types_defs.dart';

/// Agrupa os use cases de ranking (item 4.4).
abstract interface class IRankingFacade {
  Future<RankingResult> gerarRankingPessoal(NoParams params);
  Future<RankingResult> gerarRankingGlobal(NoParams params);
}
