import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/facades/i_pessoa_facade.dart';
import '../../domain/models/pessoa.dart';

/// Commands de cadastro de pessoas (item 4.5).

final class CadastrarPessoaCommand
    extends ParameterizedCommand<Pessoa, Failure, PessoaParams> {
  final IPessoaFacade _facade;

  CadastrarPessoaCommand(this._facade);

  @override
  Future<PessoaResult> execute() async {
    final params = parameter;
    if (params == null) return Error(InputFailure());
    return _facade.cadastrar(params);
  }
}

final class AlterarPessoaCommand
    extends ParameterizedCommand<Pessoa, Failure, PessoaParams> {
  final IPessoaFacade _facade;

  AlterarPessoaCommand(this._facade);

  @override
  Future<PessoaResult> execute() async {
    final params = parameter;
    if (params == null) return Error(InputFailure());
    return _facade.alterar(params);
  }
}

final class RemoverPessoaCommand
    extends ParameterizedCommand<void, Failure, IdParams> {
  final IPessoaFacade _facade;

  RemoverPessoaCommand(this._facade);

  @override
  Future<VoidResult> execute() async {
    final params = parameter;
    if (params == null) return Error(InputFailure());
    return _facade.remover(params);
  }
}

final class ListarPessoasCommand
    extends ParameterizedCommand<List<Pessoa>, Failure, NoParams> {
  final IPessoaFacade _facade;

  ListarPessoasCommand(this._facade);

  @override
  Future<ListPessoaResult> execute() => _facade.listar(());
}

final class BuscarPessoaCommand
    extends ParameterizedCommand<Pessoa, Failure, IdParams> {
  final IPessoaFacade _facade;

  BuscarPessoaCommand(this._facade);

  @override
  Future<PessoaResult> execute() async {
    final params = parameter;
    if (params == null) return Error(InputFailure());
    return _facade.buscar(params);
  }
}
