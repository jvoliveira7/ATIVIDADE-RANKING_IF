import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/facades/i_auth_facade.dart';
import '../../domain/models/pessoa.dart';
import '../../domain/models/usuario.dart';

/// Commands de autenticação (item 4.5). Cada um encapsula uma ação da
/// interface e expõe `isExecuting` e `result` como signals, para a tela
/// reagir sem `setState`.

final class LoginCommand
    extends ParameterizedCommand<Usuario, Failure, SignInParams> {
  final IAuthFacade _facade;

  LoginCommand(this._facade);

  @override
  Future<UsuarioResult> execute() async {
    final params = parameter;
    if (params == null) {
      return Error(InputFailure('Informe e-mail e senha.'));
    }
    return _facade.login(params);
  }
}

final class LoginGoogleCommand
    extends ParameterizedCommand<Usuario, Failure, NoParams> {
  final IAuthFacade _facade;

  LoginGoogleCommand(this._facade);

  @override
  Future<UsuarioResult> execute() => _facade.loginComGoogle(());
}

final class CriarContaCommand
    extends ParameterizedCommand<Usuario, Failure, SignUpParams> {
  final IAuthFacade _facade;

  CriarContaCommand(this._facade);

  @override
  Future<UsuarioResult> execute() async {
    final params = parameter;
    if (params == null) {
      return Error(InputFailure('Preencha os dados do cadastro.'));
    }
    return _facade.criarConta(params);
  }
}

/// Verifica se existe sessão válida e devolve o perfil completo do usuário
/// (com o `pessoaId`). É o que a splash dispara antes de liberar a navegação
/// (item 18).
final class VerificarSessaoCommand
    extends ParameterizedCommand<Usuario, Failure, NoParams> {
  final IAuthFacade _facade;

  VerificarSessaoCommand(this._facade);

  @override
  Future<UsuarioResult> execute() => _facade.verificarAutenticacao(());
}

final class LogoutCommand
    extends ParameterizedCommand<void, Failure, NoParams> {
  final IAuthFacade _facade;

  LogoutCommand(this._facade);

  @override
  Future<VoidResult> execute() => _facade.logout(());
}

final class CompletarPerfilCommand
    extends ParameterizedCommand<Pessoa, Failure, CompletarPerfilParams> {
  final IAuthFacade _facade;

  CompletarPerfilCommand(this._facade);

  @override
  Future<PessoaResult> execute() async {
    final params = parameter;
    if (params == null) {
      return Error(InputFailure('Preencha os dados do seu perfil.'));
    }
    return _facade.completarPerfil(params);
  }
}
