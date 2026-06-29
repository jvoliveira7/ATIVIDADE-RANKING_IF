import '../../core/typedefs/types_defs.dart';
import '../usecases/aluno_usecases_interfaces.dart';
import 'aluno_facade_usecases_interface.dart';

/// Implementação da facade: recebe os 6 use cases via injeção de
/// dependência e apenas delega cada chamada ao use case correspondente.
/// Não contém lógica própria — sua única responsabilidade é simplificar
/// o acesso da ViewModel ao domínio
final class AlunoFacadeUseCasesImpl implements IAlunoFacadeUseCases {
  final ICadastrarAlunoUseCase _cadastrarAluno;
  final IBuscarTodosAlunosUseCase _buscarTodosAlunos;
  final IBuscarAlunoPorIdUseCase _buscarAlunoPorId;
  final IAlterarAlunoUseCase _alterarAluno;
  final IRemoverAlunoUseCase _removerAluno;
  final ICalcularRankingUseCase _calcularRanking;

  AlunoFacadeUseCasesImpl({
    required ICadastrarAlunoUseCase cadastrarAluno,
    required IBuscarTodosAlunosUseCase buscarTodosAlunos,
    required IBuscarAlunoPorIdUseCase buscarAlunoPorId,
    required IAlterarAlunoUseCase alterarAluno,
    required IRemoverAlunoUseCase removerAluno,
    required ICalcularRankingUseCase calcularRanking,
  })  : _cadastrarAluno = cadastrarAluno,
        _buscarTodosAlunos = buscarTodosAlunos,
        _buscarAlunoPorId = buscarAlunoPorId,
        _alterarAluno = alterarAluno,
        _removerAluno = removerAluno,
        _calcularRanking = calcularRanking;

  @override
  Future<AlunoResult> cadastrarAluno(AlunoParams params) {
    return _cadastrarAluno(params);
  }

  @override
  Future<ListAlunoResult> buscarTodosAlunos(NoParams params) {
    return _buscarTodosAlunos(params);
  }

  @override
  Future<AlunoResult> buscarAlunoPorId(AlunoIdParams params) {
    return _buscarAlunoPorId(params);
  }

  @override
  Future<AlunoResult> alterarAluno(AlunoParams params) {
    return _alterarAluno(params);
  }

  @override
  Future<BoolResult> removerAluno(AlunoIdParams params) {
    return _removerAluno(params);
  }

  @override
  Future<ListAlunoResult> calcularRanking(NoParams params) {
    return _calcularRanking(params);
  }
}
