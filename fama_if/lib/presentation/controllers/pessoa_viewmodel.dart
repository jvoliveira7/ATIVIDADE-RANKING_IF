import '../../domain/facades/i_pessoa_facade.dart';
import 'pessoa_commands_viewmodel.dart';
import 'pessoa_state_viewmodel.dart';

/// ViewModel das telas de pessoas (item 4.5).
class PessoaViewModel {
  final PessoaState state;
  final PessoaCommandsViewModel commands;

  factory PessoaViewModel({required IPessoaFacade facade}) {
    final state = PessoaState();
    return PessoaViewModel._(
      state: state,
      commands: PessoaCommandsViewModel(state: state, facade: facade),
    );
  }

  PessoaViewModel._({required this.state, required this.commands});
}
