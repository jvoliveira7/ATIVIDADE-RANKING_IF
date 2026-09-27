import '../../domain/facades/i_ranking_facade.dart';
import 'ranking_commands_viewmodel.dart';
import 'ranking_state_viewmodel.dart';

/// ViewModel das telas de ranking (item 4.5).
class RankingViewModel {
  final RankingState state;
  final RankingCommandsViewModel commands;

  factory RankingViewModel({required IRankingFacade facade}) {
    final state = RankingState();
    return RankingViewModel._(
      state: state,
      commands: RankingCommandsViewModel(state: state, facade: facade),
    );
  }

  RankingViewModel._({required this.state, required this.commands});
}
