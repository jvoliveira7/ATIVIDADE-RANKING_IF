import '../../core/patterns/i_usecases.dart';
import '../../core/typedefs/types_defs.dart';

/// Use cases de preferências locais (item 4.3).

abstract interface class IAlterarTemaUseCase
    implements IUseCase<VoidResult, TemaParams> {}

abstract interface class ICarregarTemaUseCase
    implements IUseCase<BoolResult, NoParams> {}
