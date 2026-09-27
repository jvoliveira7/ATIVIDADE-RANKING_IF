import '../../core/typedefs/types_defs.dart';

/// Agrupa os use cases de pessoas (item 4.4).
abstract interface class IPessoaFacade {
  Future<PessoaResult> cadastrar(PessoaParams params);
  Future<PessoaResult> buscar(IdParams params);
  Future<ListPessoaResult> listar(NoParams params);
  Future<PessoaResult> alterar(PessoaParams params);
  Future<VoidResult> remover(IdParams params);
}
