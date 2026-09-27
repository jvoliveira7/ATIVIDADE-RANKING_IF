import '../../core/patterns/i_usecases.dart';
import '../../core/typedefs/types_defs.dart';

/// Use cases de avaliação (item 4.3).

abstract interface class IRegistrarAvaliacaoUseCase
    implements IUseCase<AvaliacaoResult, AvaliarParams> {}

abstract interface class IAlterarAvaliacaoUseCase
    implements IUseCase<AvaliacaoResult, AvaliarParams> {}

/// Avaliação que o usuário autenticado deu para uma pessoa, se já existir.
abstract interface class IConsultarAvaliacaoUseCase
    implements IUseCase<AvaliacaoResult, IdParams> {}

abstract interface class IBuscarAvaliacoesDoUsuarioUseCase
    implements IUseCase<ListAvaliacaoResult, NoParams> {}

/// Responde se avaliar a pessoa informada seria autoavaliação (item 14.12).
abstract interface class IVerificarAutoavaliacaoUseCase
    implements IUseCase<BoolResult, IdParams> {}
