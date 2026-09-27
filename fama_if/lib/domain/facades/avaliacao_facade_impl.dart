import '../../core/typedefs/types_defs.dart';
import '../usecases/i_avaliacao_usecases.dart';
import 'i_avaliacao_facade.dart';

/// Implementação da facade de avaliações: só delega (item 4.4).
final class AvaliacaoFacadeImpl implements IAvaliacaoFacade {
  final IRegistrarAvaliacaoUseCase _registrar;
  final IAlterarAvaliacaoUseCase _alterar;
  final IConsultarAvaliacaoUseCase _consultar;
  final IBuscarAvaliacoesDoUsuarioUseCase _buscarDoUsuario;
  final IVerificarAutoavaliacaoUseCase _verificarAutoavaliacao;

  AvaliacaoFacadeImpl({
    required IRegistrarAvaliacaoUseCase registrar,
    required IAlterarAvaliacaoUseCase alterar,
    required IConsultarAvaliacaoUseCase consultar,
    required IBuscarAvaliacoesDoUsuarioUseCase buscarDoUsuario,
    required IVerificarAutoavaliacaoUseCase verificarAutoavaliacao,
  })  : _registrar = registrar,
        _alterar = alterar,
        _consultar = consultar,
        _buscarDoUsuario = buscarDoUsuario,
        _verificarAutoavaliacao = verificarAutoavaliacao;

  @override
  Future<AvaliacaoResult> avaliar(AvaliarParams params) => _registrar(params);

  @override
  Future<AvaliacaoResult> alterarAvaliacao(AvaliarParams params) =>
      _alterar(params);

  @override
  Future<AvaliacaoResult> consultarAvaliacao(IdParams params) =>
      _consultar(params);

  @override
  Future<ListAvaliacaoResult> carregarAvaliacoes(NoParams params) =>
      _buscarDoUsuario(params);

  @override
  Future<BoolResult> verificarAutoavaliacao(IdParams params) =>
      _verificarAutoavaliacao(params);
}
