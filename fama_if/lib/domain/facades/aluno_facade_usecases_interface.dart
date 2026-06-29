import '../../core/typedefs/types_defs.dart';

/// Agrupa todos os use cases de Aluno numa única interface.
/// A ViewModel depende apenas desta facade, em vez de conhecer e injetar
/// 6 use cases separados — isso simplifica a camada de apresentação e
/// evita que a ViewModel precise saber como o domínio está organizado
/// internamente.
abstract interface class IAlunoFacadeUseCases {
  Future<AlunoResult> cadastrarAluno(AlunoParams params);
  Future<ListAlunoResult> buscarTodosAlunos(NoParams params);
  Future<AlunoResult> buscarAlunoPorId(AlunoIdParams params);
  Future<AlunoResult> alterarAluno(AlunoParams params);
  Future<BoolResult> removerAluno(AlunoIdParams params);
  Future<ListAlunoResult> calcularRanking(NoParams params);
}
