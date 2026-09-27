import '../../core/typedefs/types_defs.dart';
import '../usecases/i_pessoa_usecases.dart';
import 'i_pessoa_facade.dart';

/// Implementação da facade de pessoas: só delega (item 4.4).
final class PessoaFacadeImpl implements IPessoaFacade {
  final ICadastrarPessoaUseCase _cadastrar;
  final IBuscarPessoaPorIdUseCase _buscarPorId;
  final IBuscarTodasPessoasUseCase _buscarTodas;
  final IAlterarPessoaUseCase _alterar;
  final IRemoverPessoaUseCase _remover;

  PessoaFacadeImpl({
    required ICadastrarPessoaUseCase cadastrar,
    required IBuscarPessoaPorIdUseCase buscarPorId,
    required IBuscarTodasPessoasUseCase buscarTodas,
    required IAlterarPessoaUseCase alterar,
    required IRemoverPessoaUseCase remover,
  })  : _cadastrar = cadastrar,
        _buscarPorId = buscarPorId,
        _buscarTodas = buscarTodas,
        _alterar = alterar,
        _remover = remover;

  @override
  Future<PessoaResult> cadastrar(PessoaParams params) => _cadastrar(params);

  @override
  Future<PessoaResult> buscar(IdParams params) => _buscarPorId(params);

  @override
  Future<ListPessoaResult> listar(NoParams params) => _buscarTodas(params);

  @override
  Future<PessoaResult> alterar(PessoaParams params) => _alterar(params);

  @override
  Future<VoidResult> remover(IdParams params) => _remover(params);
}
