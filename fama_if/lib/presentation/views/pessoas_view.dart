import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_routes_constants.dart';
import '../controllers/pessoa_viewmodel.dart';
import '../widgets/app_drawer.dart';
import '../widgets/pessoa_card.dart';

/// Lista as pessoas cadastradas (item 14.6). É a tela inicial da área
/// autenticada, de onde se chega ao cadastro, aos detalhes e à avaliação.
///
/// A lista é comum a todos os usuários: é o mesmo conjunto de pessoas que
/// todo mundo avalia, e é isso que dá sentido ao ranking global (item 13).
class PessoasView extends StatefulWidget {
  const PessoasView({super.key});

  @override
  State<PessoasView> createState() => _PessoasViewState();
}

class _PessoasViewState extends State<PessoasView> {
  late final PessoaViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = injector.get<PessoaViewModel>();
    _viewModel.commands.listar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pessoas do campus')),
      drawer: const AppDrawer(rotaAtual: AppRouteNames.pessoas),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(AppRouteNames.pessoaForm),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Cadastrar pessoa'),
      ),
      body: Watch((context) {
        final carregando = _viewModel.state.carregando.value;
        final pessoas = _viewModel.state.pessoas.value;
        final erro = _viewModel.state.erro.value;

        if (carregando && pessoas.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (erro != null && pessoas.isEmpty) {
          return _EstadoVazio(
            icone: Icons.cloud_off_rounded,
            titulo: 'Não deu para carregar',
            descricao: erro,
            textoBotao: 'Tentar de novo',
            onPressed: () => _viewModel.commands.listar(),
          );
        }

        if (pessoas.isEmpty) {
          return _EstadoVazio(
            icone: Icons.groups_outlined,
            titulo: 'Ninguém cadastrado ainda',
            descricao:
                'Cadastre a primeira pessoa do campus para começar a avaliar.',
            textoBotao: 'Cadastrar pessoa',
            onPressed: () => context.pushNamed(AppRouteNames.pessoaForm),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _viewModel.commands.listar(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: pessoas.length,
            itemBuilder: (context, index) {
              final pessoa = pessoas[index];
              return PessoaCard(
                pessoa: pessoa,
                onTap: () => context.pushNamed(
                  AppRouteNames.pessoaDetalhes,
                  pathParameters: {'id': pessoa.id},
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
  final IconData icone;
  final String titulo;
  final String descricao;
  final String textoBotao;
  final VoidCallback onPressed;

  const _EstadoVazio({
    required this.icone,
    required this.titulo,
    required this.descricao,
    required this.textoBotao,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 80, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text(titulo, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              descricao,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: onPressed, child: Text(textoBotao)),
          ],
        ),
      ),
    );
  }
}
