import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_routes_constants.dart';
import '../controllers/ranking_viewmodel.dart';
import '../widgets/app_drawer.dart';
import '../widgets/lista_ranking.dart';

/// Ranking global (item 13): responde "na opinião dos usuários do app, quem
/// tem o maior Nível Lenda?".
///
/// Como a mesma pessoa recebe avaliações de vários usuários, a pontuação
/// exibida é a **média** das avaliações recebidas, acompanhada da quantidade
/// que entrou na conta.
class RankingGlobalView extends StatefulWidget {
  const RankingGlobalView({super.key});

  @override
  State<RankingGlobalView> createState() => _RankingGlobalViewState();
}

class _RankingGlobalViewState extends State<RankingGlobalView> {
  late final RankingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = injector.get<RankingViewModel>();
    _viewModel.commands.carregarGlobal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking global'),
        bottom: const _Legenda(texto: 'Na opinião do campus'),
      ),
      drawer: const AppDrawer(rotaAtual: AppRouteNames.rankingGlobal),
      body: Watch((context) {
        final carregando = _viewModel.state.carregando.value;
        final itens = _viewModel.state.global.value;

        if (carregando && itens.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (itens.isEmpty) {
          return const RankingVazio(
            titulo: 'Nenhuma avaliação ainda',
            descricao: 'Assim que as pessoas do campus forem avaliadas, o '
                'ranking global aparece aqui.',
          );
        }

        return ListaRanking(
          itens: itens,
          mostrarQuantidade: true,
          onRefresh: () => _viewModel.commands.carregarGlobal(),
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
               color: Theme.of(context).colorScheme.onSurface.withValues(
                    alpha: 0.7,
                  ),
            ),
      ),
    );
  }
}
