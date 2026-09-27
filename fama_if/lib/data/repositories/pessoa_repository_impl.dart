import '../../core/typedefs/types_defs.dart';
import '../../domain/models/pessoa.dart';
import '../services/i_pessoa_service.dart';
import 'i_pessoa_repository.dart';

/// Repositório de pessoas: repassa as chamadas ao service, que é quem conhece
/// o Firestore (item 4.2). É essa indireção que permite trocar a fonte de
/// dados sem mexer em use cases, viewmodels ou telas.
final class PessoaRepositoryImpl implements IPessoaRepository {
  final IPessoaService _service;

  PessoaRepositoryImpl({required IPessoaService service}) : _service = service;

  @override
  Future<PessoaResult> cadastrar(Pessoa pessoa) => _service.salvar(pessoa);

  @override
  Future<PessoaResult> alterar(Pessoa pessoa) => _service.atualizar(pessoa);

  @override
  Future<VoidResult> remover(String id) => _service.remover(id);

  @override
  Future<ListPessoaResult> buscarTodas() => _service.buscarTodas();

  @override
  Future<PessoaResult> buscarPorId(String id) => _service.buscarPorId(id);

  @override
  Future<PessoaResult> buscarPorUsuarioUid(String usuarioUid) =>
      _service.buscarPorUsuarioUid(usuarioUid);
}
