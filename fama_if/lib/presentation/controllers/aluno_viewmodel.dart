import '../../domain/facades/aluno_facade_usecases_interface.dart';
import 'aluno_commands_viewmodel.dart';
import 'aluno_state_viewmodel.dart';

/// ViewModel principal de Aluno: junta o [AlunoStateViewModel] (o que a
/// UI lê) e o [AlunoCommandsViewModel] (o que a UI dispara) em um único
/// objeto, que é o que de fato é injetado nas Views via DI.
///
/// As Views nunca interagem diretamente com a facade, repository ou
/// service — elas só conhecem este ViewModel.
class AlunoViewModel {
  final AlunoStateViewModel state;
  final AlunoCommandsViewModel commands;

  /// Importante: o [state] é criado uma única vez aqui e a MESMA
  /// instância é passada para o [AlunoCommandsViewModel]. Assim, quando
  /// um Command termina e atualiza `state.alunos.value` (por exemplo), a
  /// View que está observando `viewModel.state.alunos` recebe a
  /// atualização — porque ambos apontam para o mesmo objeto.
  factory AlunoViewModel({required IAlunoFacadeUseCases facade}) {
    final state = AlunoStateViewModel();
    final commands = AlunoCommandsViewModel(facade: facade, state: state);
    return AlunoViewModel._(state: state, commands: commands);
  }

  AlunoViewModel._({required this.state, required this.commands});

  void dispose() => commands.dispose();
}
