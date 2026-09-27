import '../../core/typedefs/types_defs.dart';
import '../../domain/models/avaliacao.dart';

/// Contrato do serviço de avaliações (item 4.1).
abstract interface class IAvaliacaoService {
  /// Grava a avaliação no documento cujo id é `avaliadorUid_pessoaId`.
  /// Regravar o mesmo par substitui a avaliação anterior, que é exatamente a
  /// regra "usuário + pessoa avaliada = uma avaliação" do item 16.
  Future<AvaliacaoResult> salvar(Avaliacao avaliacao);

  /// Avaliação que um usuário deu para uma pessoa, se já existir.
  Future<AvaliacaoResult> buscarPorAvaliadorEPessoa({
    required String avaliadorUid,
    required String pessoaId,
  });

  /// Todas as avaliações feitas pelo usuário — base do ranking pessoal (item 12).
  Future<ListAvaliacaoResult> buscarPorAvaliador(String avaliadorUid);

  /// Todas as avaliações de todos os usuários — base do ranking global (item 13).
  Future<ListAvaliacaoResult> buscarTodas();

  Future<VoidResult> remover(String id);
}
