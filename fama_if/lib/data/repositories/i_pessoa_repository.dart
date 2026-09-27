import '../../core/typedefs/types_defs.dart';
import '../../domain/models/pessoa.dart';

/// Contrato do repositório de pessoas (item 4.2).
abstract interface class IPessoaRepository {
  Future<PessoaResult> cadastrar(Pessoa pessoa);
  Future<PessoaResult> alterar(Pessoa pessoa);
  Future<VoidResult> remover(String id);
  Future<ListPessoaResult> buscarTodas();
  Future<PessoaResult> buscarPorId(String id);
  Future<PessoaResult> buscarPorUsuarioUid(String usuarioUid);
}
