import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/facades/i_ranking_facade.dart';
import '../../domain/models/item_ranking.dart';

/// Commands de ranking (item 4.5).

final class CarregarRankingPessoalCommand
    extends ParameterizedCommand<List<ItemRanking>, Failure, NoParams> {
  final IRankingFacade _facade;

  CarregarRankingPessoalCommand(this._facade);

  @override
  Future<RankingResult> execute() => _facade.gerarRankingPessoal(());
}

final class CarregarRankingGlobalCommand
    extends ParameterizedCommand<List<ItemRanking>, Failure, NoParams> {
  final IRankingFacade _facade;

  CarregarRankingGlobalCommand(this._facade);

  @override
  Future<RankingResult> execute() => _facade.gerarRankingGlobal(());
}
