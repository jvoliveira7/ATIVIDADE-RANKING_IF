import '../../core/typedefs/types_defs.dart';
import '../usecases/i_auth_usecases.dart';
import 'i_auth_facade.dart';

/// Implementação da facade de autenticação: só delega (item 4.4).
final class AuthFacadeImpl implements IAuthFacade {
  final ICadastrarUsuarioUseCase _cadastrarUsuario;
  final IEntrarComEmailUseCase _entrarComEmail;
  final IEntrarComGoogleUseCase _entrarComGoogle;
  final IVerificarUsuarioAutenticadoUseCase _verificarAutenticado;
  final ISairUseCase _sair;
  final ICompletarPerfilUseCase _completarPerfil;

  AuthFacadeImpl({
    required ICadastrarUsuarioUseCase cadastrarUsuario,
    required IEntrarComEmailUseCase entrarComEmail,
    required IEntrarComGoogleUseCase entrarComGoogle,
    required IVerificarUsuarioAutenticadoUseCase verificarAutenticado,
    required ISairUseCase sair,
    required ICompletarPerfilUseCase completarPerfil,
  })  : _cadastrarUsuario = cadastrarUsuario,
        _entrarComEmail = entrarComEmail,
        _entrarComGoogle = entrarComGoogle,
        _verificarAutenticado = verificarAutenticado,
        _sair = sair,
        _completarPerfil = completarPerfil;

  @override
  Future<UsuarioResult> criarConta(SignUpParams params) =>
      _cadastrarUsuario(params);

  @override
  Future<UsuarioResult> login(SignInParams params) => _entrarComEmail(params);

  @override
  Future<UsuarioResult> loginComGoogle(NoParams params) =>
      _entrarComGoogle(params);

  @override
  Future<UsuarioResult> verificarAutenticacao(NoParams params) =>
      _verificarAutenticado(params);

  @override
  Future<VoidResult> logout(NoParams params) => _sair(params);

  @override
  Future<PessoaResult> completarPerfil(CompletarPerfilParams params) =>
      _completarPerfil(params);
}
