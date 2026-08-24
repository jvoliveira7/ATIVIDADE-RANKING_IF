import '../../core/typedefs/types_defs.dart';
import '../../domain/models/aluno.dart';
import '../services/aluno_local_storage_interface.dart';
import 'aluno_repository_interface.dart';

/// Implementação do repository de Aluno.
/// Não tem lógica própria: apenas repassa as chamadas para o service
/// injetado (`_localStorage`), que é quem efetivamente acessa a fonte
/// de dados (atualmente, um banco SQLite). Essa indireção é o que
/// permite trocar a fonte de dados (ex: outro banco local, ou uma API)
/// sem alterar nenhuma camada acima do repository.
final class AlunoRepositoryImpl implements IAlunoRepository {
  final IAlunoLocalStorage _localStorage;

  AlunoRepositoryImpl({required IAlunoLocalStorage localStorage})
      : _localStorage = localStorage;

  @override
  Future<AlunoResult> salvarAluno(Aluno aluno) {
    return _localStorage.salvarAluno(aluno);
  }

  @override
  Future<ListAlunoResult> buscarTodosAlunos() {
    return _localStorage.buscarTodosAlunos();
  }

  @override
  Future<AlunoResult> buscarAlunoPorId(String id) {
    return _localStorage.buscarAlunoPorId(id);
  }

  @override
  Future<AlunoResult> atualizarAluno(Aluno aluno) {
    return _localStorage.atualizarAluno(aluno);
  }

  @override
  Future<BoolResult> removerAluno(String id) {
    return _localStorage.removerAluno(id);
  }
}
