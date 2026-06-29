import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_routes_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/aluno.dart';
import '../controllers/aluno_viewmodel.dart';
import '../widgets/aluno_card.dart';
import '../widgets/app_drawer.dart';
import '../widgets/medalha_nivel_lenda.dart';

/// Tela de ranking geral de popularidade (itens 9 e 10.6 da
/// especificação), que também funciona como dashboard inicial do app:
/// destaca o "pódio" (Top 3 do ranking geral) no topo, seguido pela
/// lista completa ordenada do maior para o menor Nível Lenda.
class RankingView extends StatefulWidget {
  const RankingView({super.key});

  @override
  State<RankingView> createState() => _RankingViewState();
}

class _RankingViewState extends State<RankingView> {
  late final AlunoViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = injector.get<AlunoViewModel>();
    _viewModel.commands.calcularRanking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ranking de popularidade')),
      drawer: const AppDrawer(rotaAtual: AppRouteNames.ranking),
      body: Watch((context) {
        final carregando = _viewModel.state.carregando.value;
        final ranking = _viewModel.state.ranking.value;

        if (carregando && ranking.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ranking.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 80,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ainda não há alunos cadastrados para gerar o ranking.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final podio = ranking.take(3).toList();
        final restante = ranking.skip(3).toList();

        return RefreshIndicator(
          onRefresh: () => _viewModel.commands.calcularRanking(),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _PodioDestaque(top3: podio, onTapAluno: _abrirDetalhes),
              const SizedBox(height: 16),
              _EstatisticasCampus(alunos: ranking),
              const SizedBox(height: 8),
              if (restante.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                  child: Text(
                    'Ranking completo',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ...List.generate(restante.length, (index) {
                  final aluno = restante[index];
                  return AlunoCard(
                    aluno: aluno,
                    posicao: index + 4, // pódio já ocupou as posições 1-3
                    onTap: () => _abrirDetalhes(aluno),
                  );
                }),
              ],
              const SizedBox(height: 12),
              _MensagemDoCampus(totalAlunos: ranking.length),
            ],
          ),
        );
      }),
    );
  }

  void _abrirDetalhes(Aluno aluno) {
    context.pushNamed(
      AppRouteNames.detalhes,
      pathParameters: {'id': aluno.id},
    );
  }
}

/// Destaque visual do Top 3 geral, em formato de pódio: o 1º lugar fica
/// mais alto e ao centro, com 2º e 3º lugares laterais e mais baixos —
/// reforçando visualmente a hierarquia sem precisar de texto extra.
class _PodioDestaque extends StatelessWidget {
  final List<Aluno> top3;
  final ValueChanged<Aluno> onTapAluno;

  const _PodioDestaque({required this.top3, required this.onTapAluno});

  @override
  Widget build(BuildContext context) {
    final primeiro = top3.isNotEmpty ? top3[0] : null;
    final segundo = top3.length > 1 ? top3[1] : null;
    final terceiro = top3.length > 2 ? top3[2] : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      decoration: const BoxDecoration(
        color: AppTheme.roxoRecreio,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Text(
            'TOP 3 DO CAMPUS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
              color: AppTheme.papel.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _PodioColuna(
                  aluno: segundo,
                  posicao: 2,
                  altura: 96,
                  onTap: onTapAluno,
                ),
              ),
              Expanded(
                child: _PodioColuna(
                  aluno: primeiro,
                  posicao: 1,
                  altura: 128,
                  onTap: onTapAluno,
                ),
              ),
              Expanded(
                child: _PodioColuna(
                  aluno: terceiro,
                  posicao: 3,
                  altura: 76,
                  onTap: onTapAluno,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PodioColuna extends StatelessWidget {
  final Aluno? aluno;
  final int posicao;
  final double altura;
  final ValueChanged<Aluno> onTap;

  const _PodioColuna({
    required this.aluno,
    required this.posicao,
    required this.altura,
    required this.onTap,
  });

  Color get _corPosicao {
    switch (posicao) {
      case 1:
        return AppTheme.corOuro;
      case 2:
        return AppTheme.corPrata;
      default:
        return AppTheme.corBronze;
    }
  }

  @override
  Widget build(BuildContext context) {
    final alunoAtual = aluno;

    if (alunoAtual == null) {
      // Ainda não há aluno suficiente para essa posição do pódio.
      return Opacity(
        opacity: 0.3,
        child: Column(
          children: [
            Icon(Icons.person_outline_rounded, color: AppTheme.papel),
            SizedBox(height: altura * 0.5),
          ],
        ),
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => onTap(alunoAtual),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MedalhaNivelLenda(
            pontos: alunoAtual.nivelLenda,
            posicao: posicao,
            tamanho: posicao == 1 ? 64 : 52,
          ),
          const SizedBox(height: 8),
          Text(
            alunoAtual.nome,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: AppTheme.papel,
            ),
          ),
          Text(
            '"${alunoAtual.apelido}"',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: AppTheme.papel.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: altura * 0.35,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: _corPosicao.withValues(alpha: 0.85),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$posicao°',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Linha de estatísticas rápidas do campus: total de alunos cadastrados,
/// curso com mais alunos no ranking, e a média geral de Nível Lenda.
/// Preenche o espaço entre o pódio e a lista completa com informação
/// útil em vez de área vazia, mesmo quando há poucos alunos.
class _EstatisticasCampus extends StatelessWidget {
  final List<Aluno> alunos;

  const _EstatisticasCampus({required this.alunos});

  String get _cursoMaisPopular {
    if (alunos.isEmpty) return '—';
    final contagem = <String, int>{};
    for (final aluno in alunos) {
      final curso = aluno.curso.displayName;
      contagem[curso] = (contagem[curso] ?? 0) + 1;
    }
    final maisPopular =
        contagem.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return maisPopular.key;
  }

  double get _mediaNivelLenda {
    if (alunos.isEmpty) return 0;
    final soma = alunos.fold<int>(0, (s, a) => s + a.nivelLenda);
    return soma / alunos.length;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _CardEstatistica(
              icone: Icons.groups_rounded,
              valor: '${alunos.length}',
              rotulo: alunos.length == 1 ? 'aluno' : 'alunos',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _CardEstatistica(
              icone: Icons.menu_book_rounded,
              valor: _cursoMaisPopular,
              rotulo: 'curso em alta',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _CardEstatistica(
              icone: Icons.bar_chart_rounded,
              valor: _mediaNivelLenda.toStringAsFixed(0),
              rotulo: 'média geral',
            ),
          ),
        ],
      ),
    );
  }
}

class _CardEstatistica extends StatelessWidget {
  final IconData icone;
  final String valor;
  final String rotulo;

  const _CardEstatistica({
    required this.icone,
    required this.valor,
    required this.rotulo,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.07)),
      ),
      child: Column(
        children: [
          Icon(icone, size: 18, color: colorScheme.primary),
          const SizedBox(height: 6),
          Text(
            valor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                ),
          ),
          Text(
            rotulo,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: colorScheme.onSurface.withValues(alpha: 0.55),
                ),
          ),
        ],
      ),
    );
  }
}

/// Mensagem final com toque de humor, na mesma linguagem descontraída
/// da especificação do PiramidGame (resenha, caos controlado, etc.),
/// variando conforme o tamanho atual do ranking — dá personalidade ao
/// dashboard mesmo quando ele ainda está com poucos alunos.
class _MensagemDoCampus extends StatelessWidget {
  final int totalAlunos;

  const _MensagemDoCampus({required this.totalAlunos});

  String get _mensagem {
    if (totalAlunos <= 2) {
      return 'O campus tá meio parado... bora cadastrar mais gente pra resenha não morrer? 🎓';
    }
    if (totalAlunos <= 5) {
      return 'O Nível Lenda já tá esquentando por aqui. Quem será o próximo a entrar pro pódio?';
    }
    return 'A disputa pelo topo do Nível Lenda está cada vez mais caótica (no bom sentido).';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.tertiary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.local_fire_department_rounded, color: colorScheme.tertiary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _mensagem,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
