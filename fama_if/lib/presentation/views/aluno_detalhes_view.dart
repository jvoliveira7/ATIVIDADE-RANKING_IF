import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_routes_constants.dart';
import '../controllers/aluno_viewmodel.dart';
import '../widgets/medalha_nivel_lenda.dart';

/// Tela de visualização dos dados completos de um aluno (item 10.3),
/// incluindo as notas individuais nos 15 critérios e o Nível Lenda
/// total. A partir dela também é possível editar (10.4) ou remover
/// (10.5) o aluno.
class AlunoDetalhesView extends StatefulWidget {
  final String alunoId;

  const AlunoDetalhesView({super.key, required this.alunoId});

  @override
  State<AlunoDetalhesView> createState() => _AlunoDetalhesViewState();
}

class _AlunoDetalhesViewState extends State<AlunoDetalhesView> {
  late final AlunoViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = injector.get<AlunoViewModel>();
    _viewModel.commands.buscarAlunoPorId(widget.alunoId);
  }

  Future<void> _confirmarRemocao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover aluno'),
        content: const Text(
          'Tem certeza que deseja remover este aluno? Esta ação não pode '
          'ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    final resultado =
        await _viewModel.commands.removerAluno(widget.alunoId);

    if (!mounted) return;

    resultado.fold(
      onSuccess: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aluno removido com sucesso.')),
        );
        context.goNamed(AppRouteNames.home);
      },
      onFailure: (falha) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(falha.msg)),
        );
      },
    );
  }

  /// Calcula a idade atual a partir da data de nascimento.
  ///
  /// Não basta subtrair os anos (`hoje.year - nascimento.year`): se a
  /// pessoa ainda não fez aniversário este ano, isso contaria um ano a
  /// mais. Por exemplo, alguém nascido em outubro/2007, em junho/2026,
  /// ainda tem 18 anos (não 19) — o aniversário de outubro ainda não
  /// chegou. A correção é comparar mês e dia: se o "aniversário deste
  /// ano" ainda não ocorreu (mês atual menor, ou mesmo mês com dia
  /// atual menor), subtrai 1 da diferença simples de anos.
  int _calcularIdade(DateTime dataNascimento) {
    final hoje = DateTime.now();
    var idade = hoje.year - dataNascimento.year;

    final aniversarioJaOcorreuEsteAno =
        (hoje.month > dataNascimento.month) ||
            (hoje.month == dataNascimento.month && hoje.day >= dataNascimento.day);

    if (!aniversarioJaOcorreuEsteAno) {
      idade -= 1;
    }

    return idade;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do aluno'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Editar',
            onPressed: () => context.pushNamed(
              AppRouteNames.cadastro,
              queryParameters: {'id': widget.alunoId},
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Remover',
            onPressed: _confirmarRemocao,
          ),
        ],
      ),
      body: Watch((context) {
        final carregando = _viewModel.state.carregando.value;
        final aluno = _viewModel.state.alunoSelecionado.value;

        if (carregando && aluno == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (aluno == null || aluno.id != widget.alunoId) {
          return const Center(child: Text('Aluno não encontrado.'));
        }

        final colorScheme = Theme.of(context).colorScheme;
        final dataFormatada =
            DateFormat('dd/MM/yyyy').format(aluno.dataNascimento);
        final idade = _calcularIdade(aluno.dataNascimento);

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      aluno.nome.isNotEmpty ? aluno.nome[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    aluno.nome,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '"${aluno.apelido}"',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _LinhaInfo(
                      icone: Icons.menu_book_rounded,
                      label: 'Curso',
                      valor: aluno.curso.displayName,
                    ),
                    _LinhaInfo(
                      icone: Icons.calendar_today_rounded,
                      label: 'Turma/ano',
                      valor: '${aluno.turmaAno}',
                    ),
                    _LinhaInfo(
                      icone: Icons.cake_rounded,
                      label: 'Data de nascimento',
                      valor: '$dataFormatada ($idade anos)',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    'NÍVEL LENDA',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      fontSize: 12,
                      color: colorScheme.onSecondaryContainer.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 14),
                  MedalhaNivelLenda(pontos: aluno.nivelLenda, tamanho: 110),
                  const SizedBox(height: 10),
                  Text(
                    'de 15 a 75 pontos',
                    style: TextStyle(
                      color: colorScheme.onSecondaryContainer.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Critérios de popularidade',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...aluno.criterios.items.map(
              (item) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(item.nome),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${item.getValue(aluno.criterios)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: colorScheme.secondary,
                        ),
                      ),
                      Icon(Icons.star_rounded, color: colorScheme.secondary),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      }),
    );
  }
}

class _LinhaInfo extends StatelessWidget {
  final IconData icone;
  final String label;
  final String valor;

  const _LinhaInfo({
    required this.icone,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icone, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(
            valor,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
