import '../../core/typedefs/types_defs.dart';

/// Contrato do repositório de ranking (item 4.2).
///
/// Não calcula nada: apenas reúne, em um só lugar, os dados crus que os use
/// cases de ranking precisam. A regra de negócio — ordenar, somar e tirar
/// média — pertence à camada de use cases (itens 12 e 13).
abstract interface class IRankingRepository {
  Future<ListPessoaResult> todasPessoas();
  Future<ListAvaliacaoResult> avaliacoesDoUsuario(String avaliadorUid);
  Future<ListAvaliacaoResult> todasAvaliacoes();
}
