import '../../data/repositories/i_auth_repository.dart';
import '../../domain/facades/i_auth_facade.dart';
import 'auth_commands_viewmodel.dart';
import 'auth_state_viewmodel.dart';

/// ViewModel de autenticação: junta o estado observável e os commands numa
/// peça só, que é o que as telas conhecem (item 4.6 — a UI não enxerga
/// repositories nem services).
class AuthViewModel {
  final AuthState state;
  final AuthCommandsViewModel commands;

  factory AuthViewModel({
    required IAuthFacade facade,
    required IAuthRepository repository,
  }) {
    final state = AuthState();
    return AuthViewModel._(
      state: state,
      commands: AuthCommandsViewModel(
        state: state,
        facade: facade,
        repository: repository,
      ),
    );
  }

  AuthViewModel._({required this.state, required this.commands});
}
