import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_routes_constants.dart';
import '../../domain/models/avaliacao.dart';
import '../../domain/models/pessoa.dart';
import '../controllers/avaliacao_viewmodel.dart';
import '../controllers/pessoa_viewmodel.dart';
import '../widgets/campos_pessoa.dart';
import '../widgets/medalha_nivel_lenda.dart';

/// Detalhes de uma pessoa (item 14.7), com atalhos para avaliar (item 14.10),
/// alterar (item 14.8) e remover (item 14.9).
class PessoaDetalhesView extends StatefulWidget {
  final String pessoaId;

  const PessoaDetalhesView({super.key, required this.pessoaId});

  @override
  State<PessoaDetalhesView> createState() => _PessoaDetalhesViewState();
}

class _PessoaDetalhesViewState extends State<PessoaDetalhesView> {
  late final PessoaViewModel _pessoaViewModel;
  late final AvaliacaoViewModel _avaliacaoViewModel;

  @override
  void initState() {
    super.initState();
    _pessoaViewModel = injector.get<PessoaViewModel>();
    _avaliacaoViewModel = injector.get<AvaliacaoViewModel>();
    _carregar();
  }

  Future<void> _carregar() async {
    await _pessoaViewModel.commands.buscar(widget.pessoaId);
    await _avaliacaoViewModel.commands.prepararPara(widget.pessoaId);
  }

  Future<void> _confirmarRemocao(Pessoa pessoa) async {
    // A exclusão precisa de confirmação antes de valer (item 14.9).
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover pessoa'),
        content: Text(
          'Remover "${pessoa.nome}" do PiramidGame? Essa ação não pode ser '
          'desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmado != true || !mounted) return;

    final resultado = await _pessoaViewModel.commands.remover(pessoa.id);
    if (!mounted) return;

    resultado.fold(
      onSuccess: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pessoa removida.')),
        );
        context.pop();
      },
      onFailure: (falha) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(falha.msg)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes')),
      body: Watch((context) {
        final pessoa = _pessoaViewModel.state.selecionada.value;
        final carregando = _pessoaViewModel.state.carregando.value;

        if (pessoa == null) {
          return Center(
            child: carregando
                ? const CircularProgressIndicator()
                : const Text('Pessoa não encontrada.'),
          );
        }

        final minhaAvaliacao = _avaliacaoViewModel.state.avaliacaoAtual.value;
        final ehVoce = _avaliacaoViewModel.state.ehAutoavaliacao.value;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _Identificacao(pessoa: pessoa, ehVoce: ehVoce),
            const SizedBox(height: 24),
            if (!ehVoce) ...[
              FilledButton.icon(
                onPressed: () => context
                    .pushNamed(
                      AppRouteNames.pessoaAvaliar,
                      pathParameters: {'id': pessoa.id},
                    )
                    .then((_) => _carregar()),
                icon: const Icon(Icons.star_rounded),
                label: Text(
                  minhaAvaliacao == null
                      ? 'Avaliar esta pessoa'
                      : 'Alterar minha avaliação',
                ),
              ),
              const SizedBox(height: 20),
            ],
            if (minhaAvaliacao != null) _MinhaAvaliacao(avaliacao: minhaAvaliacao),
            const SizedBox(height: 24),
            const SecaoTitulo(titulo: 'Gerenciar cadastro'),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => context
                  .pushNamed(
                    AppRouteNames.pessoaForm,
                    queryParameters: {'id': pessoa.id},
                  )
                  .then((_) => _carregar()),
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Editar dados'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _confirmarRemocao(pessoa),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Remover pessoa'),
            ),
            const SizedBox(height: 24),
          ],
        );
      }),
    );
  }
}

class _Identificacao extends StatelessWidget {
  final Pessoa pessoa;
  final bool ehVoce;

  const _Identificacao({required this.pessoa, required this.ehVoce});

  @override
  Widget build(BuildContext context) {
    final formatador = DateFormat('dd/MM/yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    pessoa.nome,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                if (ehVoce)
                  Chip(
                    label: const Text('Você'),
                    avatar: const Icon(Icons.person_rounded, size: 18),
                  ),
              ],
            ),
            Text(
              '"${pessoa.apelido}"',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
            const SizedBox(height: 16),
            _Linha(rotulo: 'Curso', valor: pessoa.curso.displayName),
            _Linha(rotulo: 'Turma/ano', valor: '${pessoa.turmaAno}'),
            _Linha(
              rotulo: 'Nascimento',
              valor: formatador.format(pessoa.dataNascimento),
            ),
          ],
        ),
      ),
    );
  }
}

class _MinhaAvaliacao extends StatelessWidget {
  final Avaliacao avaliacao;

  const _MinhaAvaliacao({required this.avaliacao});

  @override
  Widget build(BuildContext context) {
    final formatador = DateFormat('dd/MM/yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SecaoTitulo(
          titulo: 'Minha avaliação',
          subtitulo: 'Registrada em '
              '${formatador.format(avaliacao.dataAvaliacao)}',
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    MedalhaNivelLenda(
                      pontos: avaliacao.pontuacaoTotal,
                      tamanho: 64,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Nível Lenda que você deu para esta pessoa',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 28),
                ...avaliacao.criterios.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Expanded(child: Text(item.nome)),
                        Text(
                          '${item.getValue(avaliacao.criterios)} ★',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Linha extends StatelessWidget {
  final String rotulo;
  final String valor;

  const _Linha({required this.rotulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              rotulo,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
