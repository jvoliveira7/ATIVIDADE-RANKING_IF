import '../../core/patterns/i_usecases.dart';
import '../../core/typedefs/types_defs.dart';

/// Use cases de autenticação e sessão (item 4.3).

abstract interface class ICadastrarUsuarioUseCase
    implements IUseCase<UsuarioResult, SignUpParams> {}

abstract interface class IEntrarComEmailUseCase
    implements IUseCase<UsuarioResult, SignInParams> {}

abstract interface class IEntrarComGoogleUseCase
    implements IUseCase<UsuarioResult, NoParams> {}

abstract interface class IVerificarUsuarioAutenticadoUseCase
    implements IUseCase<UsuarioResult, NoParams> {}

abstract interface class ISairUseCase
    implements IUseCase<VoidResult, NoParams> {}

/// Cria a pessoa correspondente ao usuário logado e grava o vínculo.
abstract interface class ICompletarPerfilUseCase
    implements IUseCase<PessoaResult, CompletarPerfilParams> {}
