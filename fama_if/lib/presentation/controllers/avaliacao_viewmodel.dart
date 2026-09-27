import '../../domain/facades/i_avaliacao_facade.dart';
import 'avaliacao_commands_viewmodel.dart';
import 'avaliacao_state_viewmodel.dart';

/// ViewModel da tela de avaliação (item 4.5).
class AvaliacaoViewModel {
  final AvaliacaoState state;
  final AvaliacaoCommandsViewModel commands;

  factory AvaliacaoViewModel({required IAvaliacaoFacade facade}) {
    final state = AvaliacaoState();
    return AvaliacaoViewModel._(
      state: state,
      commands: AvaliacaoCommandsViewModel(state: state, facade: facade),
    );
  }

  AvaliacaoViewModel._({required this.state, required this.commands});
}
