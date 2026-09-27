import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/facades/i_avaliacao_facade.dart';
import '../../domain/models/avaliacao.dart';

/// Commands de avaliação (item 4.5).

final class AvaliarPessoaCommand
    extends ParameterizedCommand<Avaliacao, Failure, AvaliarParams> {
  final IAvaliacaoFacade _facade;

  AvaliarPessoaCommand(this._facade);

  @override
  Future<AvaliacaoResult> execute() async {
    final params = parameter;
    if (params == null) return Error(InputFailure());
    return _facade.avaliar(params);
  }
}

final class AlterarAvaliacaoCommand
    extends ParameterizedCommand<Avaliacao, Failure, AvaliarParams> {
  final IAvaliacaoFacade _facade;

  AlterarAvaliacaoCommand(this._facade);

  @override
  Future<AvaliacaoResult> execute() async {
    final params = parameter;
    if (params == null) return Error(InputFailure());
    return _facade.alterarAvaliacao(params);
  }
}

final class ConsultarAvaliacaoCommand
    extends ParameterizedCommand<Avaliacao, Failure, IdParams> {
  final IAvaliacaoFacade _facade;

  ConsultarAvaliacaoCommand(this._facade);

  @override
  Future<AvaliacaoResult> execute() async {
    final params = parameter;
    if (params == null) return Error(InputFailure());
    return _facade.consultarAvaliacao(params);
  }
}

final class CarregarAvaliacoesCommand
    extends ParameterizedCommand<List<Avaliacao>, Failure, NoParams> {
  final IAvaliacaoFacade _facade;

  CarregarAvaliacoesCommand(this._facade);

  @override
  Future<ListAvaliacaoResult> execute() => _facade.carregarAvaliacoes(());
}

final class VerificarAutoavaliacaoCommand
    extends ParameterizedCommand<bool, Failure, IdParams> {
  final IAvaliacaoFacade _facade;

  VerificarAutoavaliacaoCommand(this._facade);

  @override
  Future<BoolResult> execute() async {
    final params = parameter;
    if (params == null) return Error(InputFailure());
    return _facade.verificarAutoavaliacao(params);
  }
}
