import '../../core/typedefs/types_defs.dart';
import '../../domain/facades/i_avaliacao_facade.dart';
import '../../domain/models/criterios_popularidade.dart';
import '../commands/avaliacao_commands.dart';
import 'avaliacao_state_viewmodel.dart';

/// Dispara os commands de avaliação e atualiza o [AvaliacaoState] (item 4.5).
class AvaliacaoCommandsViewModel {
  final AvaliacaoState state;

  late final AvaliarPessoaCommand avaliarPessoaCommand;
  late final AlterarAvaliacaoCommand alterarAvaliacaoCommand;
  late final ConsultarAvaliacaoCommand consultarAvaliacaoCommand;
  late final CarregarAvaliacoesCommand carregarAvaliacoesCommand;
  late final VerificarAutoavaliacaoCommand verificarAutoavaliacaoCommand;

  AvaliacaoCommandsViewModel({
    required this.state,
    required IAvaliacaoFacade facade,
  }) {
    avaliarPessoaCommand = AvaliarPessoaCommand(facade);
    alterarAvaliacaoCommand = AlterarAvaliacaoCommand(facade);
    consultarAvaliacaoCommand = ConsultarAvaliacaoCommand(facade);
    carregarAvaliacoesCommand = CarregarAvaliacoesCommand(facade);
    verificarAutoavaliacaoCommand = VerificarAutoavaliacaoCommand(facade);
  }

  /// Prepara a tela de avaliação de uma pessoa: descobre se é autoavaliação e
  /// carrega a avaliação existente, quando houver.
  Future<void> prepararPara(String pessoaId) async {
    state.carregando.value = true;
    state.limpar();

    final autoavaliacao =
        await verificarAutoavaliacaoCommand.executeWith((id: pessoaId));
    autoavaliacao.fold(
      onSuccess: (proprioUsuario) =>
          state.ehAutoavaliacao.value = proprioUsuario,
      onFailure: (falha) => state.erro.value = falha.msg,
    );

    final existente =
        await consultarAvaliacaoCommand.executeWith((id: pessoaId));
    // Não ter avaliação ainda é o caso normal, não um erro para a tela.
    state.avaliacaoAtual.value = existente.successValueOrNull;

    state.carregando.value = false;
  }

  /// Salva a avaliação. Usa alterar quando já existe uma, respeitando a regra
  /// de uma única avaliação ativa por par usuário + pessoa (item 16).
  Future<AvaliacaoResult> salvar({
    required String pessoaId,
    required CriteriosPopularidade criterios,
  }) async {
    state.carregando.value = true;

    final params = (pessoaId: pessoaId, criterios: criterios);
    final resultado = state.editando.value
        ? await alterarAvaliacaoCommand.executeWith(params)
        : await avaliarPessoaCommand.executeWith(params);

    state.carregando.value = false;

    resultado.fold(
      onSuccess: (avaliacao) => state.avaliacaoAtual.value = avaliacao,
      onFailure: (falha) => state.erro.value = falha.msg,
    );
    return resultado;
  }

  Future<ListAvaliacaoResult> carregarMinhasAvaliacoes() async {
    state.carregando.value = true;
    final resultado = await carregarAvaliacoesCommand.executeWith(());
    state.carregando.value = false;

    resultado.fold(
      onSuccess: (avaliacoes) => state.minhasAvaliacoes.value = avaliacoes,
      onFailure: (falha) => state.erro.value = falha.msg,
    );
    return resultado;
  }
}
