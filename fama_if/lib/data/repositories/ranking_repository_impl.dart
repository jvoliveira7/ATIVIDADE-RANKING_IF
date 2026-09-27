import '../../core/typedefs/types_defs.dart';
import '../services/i_avaliacao_service.dart';
import '../services/i_pessoa_service.dart';
import 'i_ranking_repository.dart';

/// Repositório de ranking: combina os services de pessoas e de avaliações
/// para que os use cases de ranking dependam de uma única peça (item 4.2).
final class RankingRepositoryImpl implements IRankingRepository {
  final IPessoaService _pessoaService;
  final IAvaliacaoService _avaliacaoService;

  RankingRepositoryImpl({
    required IPessoaService pessoaService,
    required IAvaliacaoService avaliacaoService,
  })  : _pessoaService = pessoaService,
        _avaliacaoService = avaliacaoService;

  @override
  Future<ListPessoaResult> todasPessoas() => _pessoaService.buscarTodas();

  @override
  Future<ListAvaliacaoResult> avaliacoesDoUsuario(String avaliadorUid) =>
      _avaliacaoService.buscarPorAvaliador(avaliadorUid);

  @override
  Future<ListAvaliacaoResult> todasAvaliacoes() =>
      _avaliacaoService.buscarTodas();
}
