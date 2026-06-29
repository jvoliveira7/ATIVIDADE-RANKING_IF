import '../../core/failure/failure.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/facades/aluno_facade_usecases_interface.dart';
import '../../domain/models/aluno.dart';
import '../commands/aluno_commands.dart';
import 'aluno_state_viewmodel.dart';

/// Instancia os Commands de Aluno e conecta o resultado de cada um ao
/// [AlunoStateViewModel], atualizando o estado assim que o Command
/// termina de executar.
///

class AlunoCommandsViewModel {
  final AlunoStateViewModel state;

  late final cadastrarAlunoCommand = CadastrarAlunoCommand(_facade);
  late final buscarTodosAlunosCommand = BuscarTodosAlunosCommand(_facade);
  late final buscarAlunoPorIdCommand = BuscarAlunoPorIdCommand(_facade);
  late final alterarAlunoCommand = AlterarAlunoCommand(_facade);
  late final removerAlunoCommand = RemoverAlunoCommand(_facade);
  late final calcularRankingCommand = CalcularRankingCommand(_facade);

  final IAlunoFacadeUseCases _facade;

  AlunoCommandsViewModel({
    required IAlunoFacadeUseCases facade,
    required this.state,
  }) : _facade = facade;

  /// Busca todos os alunos e atualiza `state.alunos` ao terminar.
  Future<ListAlunoResult> buscarTodosAlunos() async {
    state.carregando.value = true;
    final resultado = await buscarTodosAlunosCommand();
    state.carregando.value = false;

    resultado.fold(
      onSuccess: (alunos) => state.alunos.value = alunos,
      onFailure: (falha) => state.erro.value = falha,
    );
    return resultado;
  }

  /// Calcula o ranking e atualiza `state.ranking` ao terminar.
  Future<ListAlunoResult> calcularRanking() async {
    state.carregando.value = true;
    final resultado = await calcularRankingCommand();
    state.carregando.value = false;

    resultado.fold(
      onSuccess: (alunos) => state.ranking.value = alunos,
      onFailure: (falha) => state.erro.value = falha,
    );
    return resultado;
  }

  /// Busca um aluno por id e atualiza `state.alunoSelecionado` ao terminar.
  Future<AlunoResult> buscarAlunoPorId(String id) async {
    state.carregando.value = true;
    final resultado = await buscarAlunoPorIdCommand.executeWith((id: id));
    state.carregando.value = false;

    resultado.fold(
      onSuccess: (aluno) => state.alunoSelecionado.value = aluno,
      onFailure: (falha) => state.erro.value = falha,
    );
    return resultado;
  }

  /// Cadastra um novo aluno e adiciona o resultado em `state.alunos`.
  Future<AlunoResult> cadastrarAluno(Aluno aluno) async {
    state.carregando.value = true;
    final resultado = await cadastrarAlunoCommand.executeWith((aluno: aluno));
    state.carregando.value = false;

    resultado.fold(
      onSuccess: (novoAluno) =>
          state.alunos.value = [...state.alunos.value, novoAluno],
      onFailure: (falha) => state.erro.value = falha,
    );
    return resultado;
  }

  /// Altera um aluno existente e sincroniza `state.alunos` e
  /// `state.alunoSelecionado` com o resultado.
  Future<AlunoResult> alterarAluno(Aluno aluno) async {
    state.carregando.value = true;
    final resultado = await alterarAlunoCommand.executeWith((aluno: aluno));
    state.carregando.value = false;

    resultado.fold(
      onSuccess: (alunoAtualizado) {
        state.alunos.value = state.alunos.value
            .map((a) => a.id == alunoAtualizado.id ? alunoAtualizado : a)
            .toList();
        state.alunoSelecionado.value = alunoAtualizado;
      },
      onFailure: (falha) => state.erro.value = falha,
    );
    return resultado;
  }

  /// Remove um aluno e tira o registro de `state.alunos`.
  Future<BoolResult> removerAluno(String id) async {
    state.carregando.value = true;
    final resultado = await removerAlunoCommand.executeWith((id: id));
    state.carregando.value = false;

    resultado.fold(
      onSuccess: (_) => state.alunos.value =
          state.alunos.value.where((a) => a.id != id).toList(),
      onFailure: (falha) => state.erro.value = falha,
    );
    return resultado;
  }

  /// Não há mais effects para cancelar (a sincronização agora acontece
  /// via `await` direto em cada método acima), mas o método é mantido
  /// para compatibilidade com quem já chama `dispose()`.
  void dispose() {}
}
