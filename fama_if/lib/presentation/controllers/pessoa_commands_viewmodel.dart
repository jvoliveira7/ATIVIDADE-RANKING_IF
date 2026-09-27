import '../../core/typedefs/types_defs.dart';
import '../../domain/facades/i_pessoa_facade.dart';
import '../../domain/models/pessoa.dart';
import '../commands/pessoa_commands.dart';
import 'pessoa_state_viewmodel.dart';

/// Dispara os commands de pessoa e atualiza o [PessoaState] ao final de cada
/// operação (item 4.5).
class PessoaCommandsViewModel {
  final PessoaState state;

  late final CadastrarPessoaCommand cadastrarPessoaCommand;
  late final AlterarPessoaCommand alterarPessoaCommand;
  late final RemoverPessoaCommand removerPessoaCommand;
  late final ListarPessoasCommand listarPessoasCommand;
  late final BuscarPessoaCommand buscarPessoaCommand;

  PessoaCommandsViewModel({
    required this.state,
    required IPessoaFacade facade,
  }) {
    cadastrarPessoaCommand = CadastrarPessoaCommand(facade);
    alterarPessoaCommand = AlterarPessoaCommand(facade);
    removerPessoaCommand = RemoverPessoaCommand(facade);
    listarPessoasCommand = ListarPessoasCommand(facade);
    buscarPessoaCommand = BuscarPessoaCommand(facade);
  }

  Future<ListPessoaResult> listar() async {
    state.carregando.value = true;
    final resultado = await listarPessoasCommand.executeWith(());
    state.carregando.value = false;

    resultado.fold(
      onSuccess: (pessoas) => state.pessoas.value = pessoas,
      onFailure: (falha) => state.erro.value = falha.msg,
    );
    return resultado;
  }

  Future<PessoaResult> buscar(String id) async {
    state.carregando.value = true;
    final resultado = await buscarPessoaCommand.executeWith((id: id));
    state.carregando.value = false;

    resultado.fold(
      onSuccess: (pessoa) => state.selecionada.value = pessoa,
      onFailure: (falha) => state.erro.value = falha.msg,
    );
    return resultado;
  }

  Future<PessoaResult> cadastrar(Pessoa pessoa) async {
    state.carregando.value = true;
    final resultado = await cadastrarPessoaCommand.executeWith((pessoa: pessoa));
    state.carregando.value = false;

    resultado.fold(
      onSuccess: (nova) => state.pessoas.value = [...state.pessoas.value, nova],
      onFailure: (falha) => state.erro.value = falha.msg,
    );
    return resultado;
  }

  Future<PessoaResult> alterar(Pessoa pessoa) async {
    state.carregando.value = true;
    final resultado = await alterarPessoaCommand.executeWith((pessoa: pessoa));
    state.carregando.value = false;

    resultado.fold(
      onSuccess: (alterada) {
        state.pessoas.value = state.pessoas.value
            .map((p) => p.id == alterada.id ? alterada : p)
            .toList();
        state.selecionada.value = alterada;
      },
      onFailure: (falha) => state.erro.value = falha.msg,
    );
    return resultado;
  }

  Future<VoidResult> remover(String id) async {
    state.carregando.value = true;
    final resultado = await removerPessoaCommand.executeWith((id: id));
    state.carregando.value = false;

    resultado.fold(
      onSuccess: (_) {
        state.pessoas.value =
            state.pessoas.value.where((p) => p.id != id).toList();
        if (state.selecionada.value?.id == id) state.selecionada.value = null;
      },
      onFailure: (falha) => state.erro.value = falha.msg,
    );
    return resultado;
  }
}
