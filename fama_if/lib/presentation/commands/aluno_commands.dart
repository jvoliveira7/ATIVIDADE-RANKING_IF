import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/facades/aluno_facade_usecases_interface.dart';
import '../../domain/models/aluno.dart';


//Dispara o cadastro de um novo aluno.
final class CadastrarAlunoCommand
    extends ParameterizedCommand<Aluno, Failure, AlunoParams> {
  final IAlunoFacadeUseCases _facade;

  CadastrarAlunoCommand(this._facade);

  @override
  Future<Result<Aluno, Failure>> execute() async {
    final resultado = await _facade.cadastrarAluno(parameter!);
    return resultado;
  }
}

// Busca todos os alunos cadastrados (sem ordenação de ranking).
final class BuscarTodosAlunosCommand
    extends Command<List<Aluno>, Failure> {
  final IAlunoFacadeUseCases _facade;

  BuscarTodosAlunosCommand(this._facade);

  @override
  Future<Result<List<Aluno>, Failure>> execute() {
    return _facade.buscarTodosAlunos(());
  }
}

//Busca um único aluno pelo id (usado na tela de detalhes/edição).
final class BuscarAlunoPorIdCommand
    extends ParameterizedCommand<Aluno, Failure, AlunoIdParams> {
  final IAlunoFacadeUseCases _facade;

  BuscarAlunoPorIdCommand(this._facade);

  @override
  Future<Result<Aluno, Failure>> execute() {
    return _facade.buscarAlunoPorId(parameter!);
  }
}

// Altera os dados de um aluno já cadastrado
final class AlterarAlunoCommand
    extends ParameterizedCommand<Aluno, Failure, AlunoParams> {
  final IAlunoFacadeUseCases _facade;

  AlterarAlunoCommand(this._facade);

  @override
  Future<Result<Aluno, Failure>> execute() {
    return _facade.alterarAluno(parameter!);
  }
}

///Remove um aluno cadastrado
final class RemoverAlunoCommand
    extends ParameterizedCommand<bool, Failure, AlunoIdParams> {
  final IAlunoFacadeUseCases _facade;

  RemoverAlunoCommand(this._facade);

  @override
  Future<Result<bool, Failure>> execute() {
    return _facade.removerAluno(parameter!);
  }
}

///calcula o ranking geral (alunos ordenados por lenda)
final class CalcularRankingCommand extends Command<List<Aluno>, Failure> {
  final IAlunoFacadeUseCases _facade;

  CalcularRankingCommand(this._facade);

  @override
  Future<Result<List<Aluno>, Failure>> execute() {
    return _facade.calcularRanking(());
  }
}
