import '../../core/typedefs/types_defs.dart';
import '../../domain/models/aluno.dart';

/// Contrato do repository de Aluno. O repository não conhece de onde vêm
///os dados
abstract interface class IAlunoRepository {
  Future<AlunoResult> salvarAluno(Aluno aluno);
  Future<ListAlunoResult> buscarTodosAlunos();
  Future<AlunoResult> buscarAlunoPorId(String id);
  Future<AlunoResult> atualizarAluno(Aluno aluno);
  Future<BoolResult> removerAluno(String id);
}
