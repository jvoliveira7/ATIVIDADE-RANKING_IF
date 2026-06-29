import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_routes_constants.dart';
import '../controllers/aluno_viewmodel.dart';
import '../widgets/aluno_card.dart';
import '../widgets/app_drawer.dart';

/// Tela principal do app: lista os alunos cadastrados (item 10.2).
/// É a tela inicial após a Splash, e a partir dela (via drawer) o
/// usuário acessa cadastro, ranking e a tela sobre o app.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final AlunoViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = injector.get<AlunoViewModel>();
    // Carrega a lista de alunos assim que a tela abre.
    _viewModel.commands.buscarTodosAlunos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alunos cadastrados')),
      drawer: const AppDrawer(rotaAtual: AppRouteNames.home),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(AppRouteNames.cadastro),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Cadastrar aluno'),
      ),
      body: Watch((context) {
        final carregando = _viewModel.state.carregando.value;
        final alunos = _viewModel.state.alunos.value;
        final listaVazia = _viewModel.state.listaVazia.value;

        if (carregando && alunos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (listaVazia) {
          return _EstadoVazio(
            onCadastrar: () => context.pushNamed(AppRouteNames.cadastro),
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              _viewModel.commands.buscarTodosAlunos(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: alunos.length,
            itemBuilder: (context, index) {
              final aluno = alunos[index];
              return AlunoCard(
                aluno: aluno,
                onTap: () => context.pushNamed(
                  AppRouteNames.detalhes,
                  pathParameters: {'id': aluno.id},
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  final VoidCallback onCadastrar;

  const _EstadoVazio({required this.onCadastrar});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 80,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum aluno cadastrado ainda',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Cadastre o primeiro aluno para começar o ranking de '
              'popularidade do campus!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCadastrar,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Cadastrar aluno'),
            ),
          ],
        ),
      ),
    );
  }
}
