import '../../core/typedefs/types_defs.dart';
import '../../domain/models/aluno.dart';

/// Contrato para acesso direto ao armazenamento local de alunos.
/// Esta é a camada de "services" da arquitetura (services → repositories →
/// use cases → facade → viewmodel → UI): a única camada que sabe que os
/// dados estão no SharedPreferences.
abstract interface class IAlunoLocalStorage {
  Future<AlunoResult> salvarAluno(Aluno aluno);
  Future<ListAlunoResult> buscarTodosAlunos();
  Future<AlunoResult> buscarAlunoPorId(String id);
  Future<AlunoResult> atualizarAluno(Aluno aluno);
  Future<BoolResult> removerAluno(String id);
}
