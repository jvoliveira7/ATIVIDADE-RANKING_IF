import 'package:uuid/uuid.dart';

import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../data/repositories/aluno_repository_interface.dart';
import 'aluno_usecases_interfaces.dart';

/// Cadastra um novo aluno.
/// Gera um identificador único (uuid) antes de delegar ao repository,
/// já que a entidade [Aluno] exige um `id` desde a criação.
final class CadastrarAlunoUseCase implements ICadastrarAlunoUseCase {
  final IAlunoRepository _repository;
  final Uuid _uuid;

  CadastrarAlunoUseCase({required IAlunoRepository repository, Uuid? uuid})
      : _repository = repository,
        _uuid = uuid ?? const Uuid();

  @override
  Future<AlunoResult> call(AlunoParams params) async {
    // Garante um id novo mesmo que a UI já tenha enviado um (cadastro
    // sempre cria um registro novo, nunca reaproveita id existente).
    final alunoComId = params.aluno.copyWith(id: _uuid.v4());
    return _repository.salvarAluno(alunoComId);
  }
}

/// Busca todos os alunos cadastrados, sem nenhuma ordenação específica
/// (a ordenação por ranking é responsabilidade do
/// [CalcularRankingUseCase]).
final class BuscarTodosAlunosUseCase implements IBuscarTodosAlunosUseCase {
  final IAlunoRepository _repository;

  BuscarTodosAlunosUseCase({required IAlunoRepository repository})
      : _repository = repository;

  @override
  Future<ListAlunoResult> call(NoParams params) {
    return _repository.buscarTodosAlunos();
  }
}

/// Busca um único aluno pelo identificador, usado na tela de detalhes
/// e na tela de edição.
final class BuscarAlunoPorIdUseCase implements IBuscarAlunoPorIdUseCase {
  final IAlunoRepository _repository;

  BuscarAlunoPorIdUseCase({required IAlunoRepository repository})
      : _repository = repository;

  @override
  Future<AlunoResult> call(AlunoIdParams params) {
    return _repository.buscarAlunoPorId(params.id);
  }
}

/// Atualiza os dados cadastrais e/ou as notas de um aluno já existente
/// (item 10.4 da especificação).
final class AlterarAlunoUseCase implements IAlterarAlunoUseCase {
  final IAlunoRepository _repository;

  AlterarAlunoUseCase({required IAlunoRepository repository})
      : _repository = repository;

  @override
  Future<AlunoResult> call(AlunoParams params) {
    return _repository.atualizarAluno(params.aluno);
  }
}

/// Remove um aluno cadastrado (item 10.5 da especificação).
/// A confirmação antes da exclusão é responsabilidade da UI; este use
/// case apenas executa a remoção em si.
final class RemoverAlunoUseCase implements IRemoverAlunoUseCase {
  final IAlunoRepository _repository;

  RemoverAlunoUseCase({required IAlunoRepository repository})
      : _repository = repository;

  @override
  Future<BoolResult> call(AlunoIdParams params) {
    return _repository.removerAluno(params.id);
  }
}

/// Calcula o ranking de popularidade (itens 3.3 e 9 da especificação):
/// busca todos os alunos e retorna a lista ordenada do maior para o menor
/// Nível Lenda. Em caso de empate, a ordem original (de cadastro) é
/// preservada, já que `List.sort` no Dart é estável.
final class CalcularRankingUseCase implements ICalcularRankingUseCase {
  final IAlunoRepository _repository;

  CalcularRankingUseCase({required IAlunoRepository repository})
      : _repository = repository;

  @override
  Future<ListAlunoResult> call(NoParams params) async {
    final resultado = await _repository.buscarTodosAlunos();

    return resultado.fold(
      onSuccess: (alunos) {
        final ranking = [...alunos]
          ..sort((a, b) => b.nivelLenda.compareTo(a.nivelLenda));
        return Success(ranking);
      },
      onFailure: (falha) => Error(falha),
    );
  }
}
