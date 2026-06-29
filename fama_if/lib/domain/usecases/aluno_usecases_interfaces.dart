import '../../core/patterns/i_usecases.dart';
import '../../core/typedefs/types_defs.dart';

/// Cada interface representa uma única ação do domínio (item 3.3 da
/// especificação: cadastrar, alterar, remover, buscar todos, buscar por id,
/// calcular ranking). Seguindo o princípio de responsabilidade única, cada
/// use case faz exatamente uma coisa.

abstract interface class ICadastrarAlunoUseCase
    implements IUseCase<AlunoResult, AlunoParams> {}

abstract interface class IBuscarTodosAlunosUseCase
    implements IUseCase<ListAlunoResult, NoParams> {}

abstract interface class IBuscarAlunoPorIdUseCase
    implements IUseCase<AlunoResult, AlunoIdParams> {}

abstract interface class IAlterarAlunoUseCase
    implements IUseCase<AlunoResult, AlunoParams> {}

abstract interface class IRemoverAlunoUseCase
    implements IUseCase<BoolResult, AlunoIdParams> {}

/// Use case dedicado ao cálculo do ranking (item 3.3 e item 9 da
/// especificação). Busca todos os alunos e os retorna já ordenados do
/// maior para o menor Nível Lenda.
abstract interface class ICalcularRankingUseCase
    implements IUseCase<ListAlunoResult, NoParams> {}
