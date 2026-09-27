import '../../core/typedefs/types_defs.dart';
import '../../domain/models/avaliacao.dart';
import '../services/i_avaliacao_service.dart';
import 'i_avaliacao_repository.dart';

/// Repositório de avaliações (item 4.2).
final class AvaliacaoRepositoryImpl implements IAvaliacaoRepository {
  final IAvaliacaoService _service;

  AvaliacaoRepositoryImpl({required IAvaliacaoService service})
      : _service = service;

  @override
  Future<AvaliacaoResult> salvar(Avaliacao avaliacao) =>
      _service.salvar(avaliacao);

  @override
  Future<AvaliacaoResult> buscarPorAvaliadorEPessoa({
    required String avaliadorUid,
    required String pessoaId,
  }) =>
      _service.buscarPorAvaliadorEPessoa(
        avaliadorUid: avaliadorUid,
        pessoaId: pessoaId,
      );

  @override
  Future<ListAvaliacaoResult> buscarPorAvaliador(String avaliadorUid) =>
      _service.buscarPorAvaliador(avaliadorUid);

  @override
  Future<ListAvaliacaoResult> buscarTodas() => _service.buscarTodas();

  @override
  Future<VoidResult> remover(String id) => _service.remover(id);
}
