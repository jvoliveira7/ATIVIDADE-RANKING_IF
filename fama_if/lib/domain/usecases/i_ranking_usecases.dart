import '../../core/patterns/i_usecases.dart';
import '../../core/typedefs/types_defs.dart';

/// Use cases de ranking (item 4.3).

/// "Na minha opinião, quem tem o maior Nível Lenda?" (itens 12 e 25).
abstract interface class ICalcularRankingPessoalUseCase
    implements IUseCase<RankingResult, NoParams> {}

/// "Na opinião dos usuários do app, quem tem o maior Nível Lenda?"
/// (itens 13 e 25).
abstract interface class ICalcularRankingGlobalUseCase
    implements IUseCase<RankingResult, NoParams> {}
