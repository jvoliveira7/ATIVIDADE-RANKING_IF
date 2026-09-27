import '../../core/typedefs/types_defs.dart';
import '../usecases/i_ranking_usecases.dart';
import 'i_ranking_facade.dart';

/// Implementação da facade de ranking: só delega (item 4.4).
final class RankingFacadeImpl implements IRankingFacade {
  final ICalcularRankingPessoalUseCase _rankingPessoal;
  final ICalcularRankingGlobalUseCase _rankingGlobal;

  RankingFacadeImpl({
    required ICalcularRankingPessoalUseCase rankingPessoal,
    required ICalcularRankingGlobalUseCase rankingGlobal,
  })  : _rankingPessoal = rankingPessoal,
        _rankingGlobal = rankingGlobal;

  @override
  Future<RankingResult> gerarRankingPessoal(NoParams params) =>
      _rankingPessoal(params);

  @override
  Future<RankingResult> gerarRankingGlobal(NoParams params) =>
      _rankingGlobal(params);
}
