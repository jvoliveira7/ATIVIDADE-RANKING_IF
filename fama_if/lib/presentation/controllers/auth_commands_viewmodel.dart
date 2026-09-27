import 'package:signals_flutter/signals_flutter.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../core/typedefs/types_defs.dart';
import '../../data/repositories/i_auth_repository.dart';
import '../../domain/facades/i_auth_facade.dart';
import '../commands/auth_commands.dart';
import 'auth_state_viewmodel.dart';

/// Dispara os commands de autenticação e mantém o [AuthState] sincronizado
/// com o resultado de cada um (item 4.5).
class AuthCommandsViewModel {
  final AuthState state;
  final IAuthRepository _repository;

  late final LoginCommand loginCommand;
  late final LoginGoogleCommand loginGoogleCommand;
  late final CriarContaCommand criarContaCommand;
  late final LogoutCommand logoutCommand;
  late final CompletarPerfilCommand completarPerfilCommand;
  late final VerificarSessaoCommand verificarSessaoCommand;

  AuthCommandsViewModel({
    required this.state,
    required IAuthFacade facade,
    required IAuthRepository repository,
  }) : _repository = repository {
    loginCommand = LoginCommand(facade);
    loginGoogleCommand = LoginGoogleCommand(facade);
    criarContaCommand = CriarContaCommand(facade);
    logoutCommand = LogoutCommand(facade);
    completarPerfilCommand = CompletarPerfilCommand(facade);
    verificarSessaoCommand = VerificarSessaoCommand(facade);

    _observarSessao();
    _observarLogin();
    _observarLoginGoogle();
    _observarCriarConta();
    _observarLogout();
    _observarCompletarPerfil();
  }

  // ---------------------------------------------------------------------
  // Ações chamadas pelas telas
  // ---------------------------------------------------------------------

  /// Dispara a verificação de sessão da splash (item 18).
  ///
  /// Não passa pelo observador genérico de propósito: "não há ninguém logado"
  /// é uma resposta esperada aqui, e não deve virar mensagem de erro na tela
  /// de login que aparece logo em seguida.
  Future<void> verificarSessao() async {
    final resultado = await verificarSessaoCommand.executeWith(());
    resultado.fold(
      onSuccess: state.definirAutenticado,
      onFailure: (_) => state.definirNaoAutenticado(),
    );
  }

  Future<void> login(String email, String senha) async {
    state.limparMensagem();
    await loginCommand.executeWith((email: email, senha: senha));
  }

  Future<void> loginComGoogle() async {
    state.limparMensagem();
    await loginGoogleCommand.executeWith(());
  }

  Future<void> criarConta({
    required String nome,
    required String email,
    required String senha,
  }) async {
    state.limparMensagem();
    await criarContaCommand
        .executeWith((nome: nome, email: email, senha: senha));
  }

  Future<void> logout() async {
    state.limparMensagem();
    await logoutCommand.executeWith(());
  }

  Future<void> completarPerfil(CompletarPerfilParams params) async {
    state.limparMensagem();
    await completarPerfilCommand.executeWith(params);
  }

  // ---------------------------------------------------------------------
  // Observadores
  // ---------------------------------------------------------------------

  /// Acompanha a sessão do Firebase. Como o signal vem do serviço de
  /// autenticação, um logout disparado de qualquer lugar chega aqui.
  void _observarSessao() {
    effect(() {
      final usuarioFirebase = _repository.usuarioAtualSignal.value;

      if (usuarioFirebase == null) {
        state.definirNaoAutenticado();
        return;
      }

      // O Firebase não conhece o `pessoaId`, que vem do perfil no Firestore.
      // Se o perfil completo já está em memória, ele não pode ser sobrescrito
      // pela versão mais pobre — senão o app acharia que falta completar
      // o perfil a cada evento de autenticação.
      final jaCarregado = state.usuario.value;
      state.definirAutenticado(
        jaCarregado != null && jaCarregado.uid == usuarioFirebase.uid
            ? jaCarregado
            : usuarioFirebase,
      );
    });
  }

  void _observarLogin() => _observar(loginCommand, aoConcluir: state.definirAutenticado);

  void _observarLoginGoogle() =>
      _observar(loginGoogleCommand, aoConcluir: state.definirAutenticado);

  void _observarCriarConta() =>
      _observar(criarContaCommand, aoConcluir: state.definirAutenticado);

  void _observarLogout() {
    _observar<void>(
      logoutCommand,
      aoConcluir: (_) => state.definirNaoAutenticado(msg: 'Sessão encerrada.'),
    );
  }

  void _observarCompletarPerfil() {
    _observar(
      completarPerfilCommand,
      aoConcluir: (pessoa) {
        final atual = state.usuario.value;
        if (atual != null) {
          state.definirAutenticado(atual.copyWith(pessoaId: pessoa.id));
        }
      },
    );
  }

  /// Liga um command ao estado: cuida de `carregando`, das mensagens de erro
  /// e de repassar o valor em caso de sucesso.
  void _observar<T>(
    Command<T, Failure> command, {
    required void Function(T valor) aoConcluir,
  }) {
    effect(() {
      state.carregando.value = command.isExecuting.value;
      if (command.isExecuting.value) return;

      final resultado = command.result.value;
      if (resultado == null) return;

      resultado.fold(
        onSuccess: (valor) {
          state.limparMensagem();
          aoConcluir(valor);
        },
        onFailure: (falha) => state.definirMensagem(falha.msg),
      );
    });
  }
}
