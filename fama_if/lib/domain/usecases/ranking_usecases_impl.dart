import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../data/repositories/i_auth_repository.dart';
import '../../data/repositories/i_ranking_repository.dart';
import '../models/avaliacao.dart';
import '../models/item_ranking.dart';
import '../models/pessoa.dart';
import 'i_ranking_usecases.dart';

/// Ranking pessoal: considera exclusivamente as avaliações feitas pelo usuário
/// autenticado (item 12). Avaliações de outros usuários não interferem.
final class CalcularRankingPessoalUseCase
    implements ICalcularRankingPessoalUseCase {
  final IRankingRepository _repository;
  final IAuthRepository _authRepository;

  CalcularRankingPessoalUseCase({
    required IRankingRepository repository,
    required IAuthRepository authRepository,
  })  : _repository = repository,
        _authRepository = authRepository;

  @override
  Future<RankingResult> call(NoParams params) async {
    final usuario = _authRepository.usuarioAtual;
    if (usuario == null) return Error(UnauthenticatedFailure());

    final avaliacoesResult =
        await _repository.avaliacoesDoUsuario(usuario.uid);
    if (avaliacoesResult.isFailure) {
      return Error(avaliacoesResult.failureValueOrNull ?? DefaultFailure());
    }

    final pessoasResult = await _repository.todasPessoas();
    if (pessoasResult.isFailure) {
      return Error(pessoasResult.failureValueOrNull ?? DefaultFailure());
    }

    final porId = _indexarPorId(pessoasResult.successValueOrNull ?? const []);

    final itens = <ItemRanking>[];
    for (final avaliacao in avaliacoesResult.successValueOrNull ?? const []) {
      final pessoa = porId[avaliacao.pessoaId];
      // Avaliação órfã (pessoa removida depois de avaliada) é ignorada.
      if (pessoa == null) continue;

      itens.add(
        ItemRanking(
          pessoa: pessoa,
          pontuacao: avaliacao.pontuacaoTotal.toDouble(),
          quantidadeAvaliacoes: 1,
        ),
      );
    }

    itens.sort((a, b) => b.pontuacao.compareTo(a.pontuacao));
    return Success(itens);
  }
}

/// Ranking global: considera as avaliações de todos os usuários e usa a média
/// das notas recebidas por cada pessoa, exibindo também quantas avaliações
/// entraram na conta (item 13).
final class CalcularRankingGlobalUseCase
    implements ICalcularRankingGlobalUseCase {
  final IRankingRepository _repository;

  CalcularRankingGlobalUseCase({required IRankingRepository repository})
      : _repository = repository;

  @override
  Future<RankingResult> call(NoParams params) async {
    final avaliacoesResult = await _repository.todasAvaliacoes();
    if (avaliacoesResult.isFailure) {
      return Error(avaliacoesResult.failureValueOrNull ?? DefaultFailure());
    }

    final pessoasResult = await _repository.todasPessoas();
    if (pessoasResult.isFailure) {
      return Error(pessoasResult.failureValueOrNull ?? DefaultFailure());
    }

    final avaliacoes = avaliacoesResult.successValueOrNull ?? const <Avaliacao>[];
    final pessoas = pessoasResult.successValueOrNull ?? const <Pessoa>[];

    // Soma e contagem por pessoa, para depois tirar a média.
    final somaPorPessoa = <String, int>{};
    final quantidadePorPessoa = <String, int>{};

    for (final avaliacao in avaliacoes) {
      somaPorPessoa.update(
        avaliacao.pessoaId,
        (soma) => soma + avaliacao.pontuacaoTotal,
        ifAbsent: () => avaliacao.pontuacaoTotal,
      );
      quantidadePorPessoa.update(
        avaliacao.pessoaId,
        (qtd) => qtd + 1,
        ifAbsent: () => 1,
      );
    }

    final itens = <ItemRanking>[];
    for (final pessoa in pessoas) {
      final quantidade = quantidadePorPessoa[pessoa.id] ?? 0;
      // Quem ainda não recebeu avaliação fica fora do ranking.
      if (quantidade == 0) continue;

      final soma = somaPorPessoa[pessoa.id] ?? 0;
      itens.add(
        ItemRanking(
          pessoa: pessoa,
          pontuacao: soma / quantidade,
          quantidadeAvaliacoes: quantidade,
        ),
      );
    }

    itens.sort((a, b) => b.pontuacao.compareTo(a.pontuacao));
    return Success(itens);
  }
}

Map<String, Pessoa> _indexarPorId(List<Pessoa> pessoas) {
  return {for (final pessoa in pessoas) pessoa.id: pessoa};
}
