import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_routes_constants.dart';
import '../controllers/ranking_viewmodel.dart';
import '../widgets/app_drawer.dart';
import '../widgets/lista_ranking.dart';

/// Ranking pessoal (item 12): responde "na minha opinião, quem tem o maior
/// Nível Lenda?", considerando exclusivamente as avaliações do usuário
/// autenticado. O que os outros usuários avaliaram não entra aqui.
class RankingPessoalView extends StatefulWidget {
  const RankingPessoalView({super.key});

  @override
  State<RankingPessoalView> createState() => _RankingPessoalViewState();
}

class _RankingPessoalViewState extends State<RankingPessoalView> {
  late final RankingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = injector.get<RankingViewModel>();
    _viewModel.commands.carregarPessoal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking pessoal'),
        bottom: const _Legenda(texto: 'Na minha opinião'),
      ),
      drawer: const AppDrawer(rotaAtual: AppRouteNames.rankingPessoal),
      body: Watch((context) {
        final carregando = _viewModel.state.carregando.value;
        final itens = _viewModel.state.pessoal.value;

        if (carregando && itens.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (itens.isEmpty) {
          return const RankingVazio(
            titulo: 'Você ainda não avaliou ninguém',
            descricao: 'Avalie as pessoas do campus para montar o seu ranking '
                'pessoal.',
          );
        }

        return ListaRanking(
          itens: itens,
          onRefresh: () => _viewModel.commands.carregarPessoal(),
          onTap: (item) => context.pushNamed(
            AppRouteNames.pessoaDetalhes,
            pathParameters: {'id': item.pessoa.id},
          ),
        );
      }),
    );
  }
}

class _Legenda extends StatelessWidget implements PreferredSizeWidget {
  final String texto;

  const _Legenda({required this.texto});

  @override
  Size get preferredSize => const Size.fromHeight(28);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texto,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary.withValues(
                    alpha: 0.85,
                  ),
            ),
      ),
    );
  }
}
