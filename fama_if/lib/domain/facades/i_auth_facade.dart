import '../../core/typedefs/types_defs.dart';

/// Agrupa os use cases de autenticação para que a ViewModel não precise
/// conhecer cada um individualmente (item 4.4).
abstract interface class IAuthFacade {
  Future<UsuarioResult> criarConta(SignUpParams params);
  Future<UsuarioResult> login(SignInParams params);
  Future<UsuarioResult> loginComGoogle(NoParams params);
  Future<UsuarioResult> verificarAutenticacao(NoParams params);
  Future<VoidResult> logout(NoParams params);
  Future<PessoaResult> completarPerfil(CompletarPerfilParams params);
}
