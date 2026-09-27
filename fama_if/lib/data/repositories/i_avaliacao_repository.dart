import '../../core/typedefs/types_defs.dart';
import '../../domain/models/avaliacao.dart';

/// Contrato do repositório de avaliações (item 4.2).
abstract interface class IAvaliacaoRepository {
  Future<AvaliacaoResult> salvar(Avaliacao avaliacao);
  Future<AvaliacaoResult> buscarPorAvaliadorEPessoa({
    required String avaliadorUid,
    required String pessoaId,
  });
  Future<ListAvaliacaoResult> buscarPorAvaliador(String avaliadorUid);
  Future<ListAvaliacaoResult> buscarTodas();
  Future<VoidResult> remover(String id);
}
