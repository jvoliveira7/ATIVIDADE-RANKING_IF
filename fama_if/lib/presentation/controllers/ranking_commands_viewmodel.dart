import '../../core/typedefs/types_defs.dart';
import '../../domain/facades/i_ranking_facade.dart';
import '../commands/ranking_commands.dart';
import 'ranking_state_viewmodel.dart';

/// Dispara os commands de ranking e atualiza o [RankingState] (item 4.5).
class RankingCommandsViewModel {
  final RankingState state;

  late final CarregarRankingPessoalCommand carregarRankingPessoalCommand;
  late final CarregarRankingGlobalCommand carregarRankingGlobalCommand;

  RankingCommandsViewModel({
    required this.state,
    required IRankingFacade facade,
  }) {
    carregarRankingPessoalCommand = CarregarRankingPessoalCommand(facade);
    carregarRankingGlobalCommand = CarregarRankingGlobalCommand(facade);
  }

  Future<RankingResult> carregarPessoal() async {
    state.carregando.value = true;
    final resultado = await carregarRankingPessoalCommand.executeWith(());
    state.carregando.value = false;

    resultado.fold(
      onSuccess: (itens) => state.pessoal.value = itens,
      onFailure: (falha) => state.erro.value = falha.msg,
    );
    return resultado;
  }

  Future<RankingResult> carregarGlobal() async {
    state.carregando.value = true;
    final resultado = await carregarRankingGlobalCommand.executeWith(());
    state.carregando.value = false;

    resultado.fold(
      onSuccess: (itens) => state.global.value = itens,
      onFailure: (falha) => state.erro.value = falha.msg,
    );
    return resultado;
  }
}
