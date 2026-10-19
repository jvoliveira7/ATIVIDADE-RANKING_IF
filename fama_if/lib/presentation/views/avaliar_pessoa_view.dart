import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/di/dependency_injection.dart';
import '../../domain/models/criterios_popularidade.dart';
import '../controllers/avaliacao_viewmodel.dart';
import '../controllers/pessoa_viewmodel.dart';
import '../widgets/aviso_erro.dart';
import '../widgets/campos_pessoa.dart';
import '../widgets/criterio_estrelas.dart';
import '../widgets/medalha_nivel_lenda.dart';

/// Tela de avaliação (itens 14.10 e 14.11): 15 critérios com nota de 1 a 5
/// estrelas, somando o Nível Lenda daquela avaliação.
///
/// Se o usuário já avaliou esta pessoa, a tela abre com as notas anteriores e
/// passa a alterar a avaliação existente, em vez de criar outra — é a regra
/// de uma avaliação ativa por par usuário + pessoa (item 16). E se a pessoa
/// for o próprio usuário, nem chega a permitir a edição (item 14.12).
class AvaliarPessoaView extends StatefulWidget {
  final String pessoaId;

  const AvaliarPessoaView({super.key, required this.pessoaId});

  @override
  State<AvaliarPessoaView> createState() => _AvaliarPessoaViewState();
}

class _AvaliarPessoaViewState extends State<AvaliarPessoaView> {
  late final AvaliacaoViewModel _avaliacaoViewModel;
  late final PessoaViewModel _pessoaViewModel;

  CriteriosPopularidade _criterios = CriteriosPopularidade.inicial();
  bool _preparando = true;

  @override
  void initState() {
    super.initState();
    _avaliacaoViewModel = injector.get<AvaliacaoViewModel>();
    _pessoaViewModel = injector.get<PessoaViewModel>();
    _preparar();
  }

  Future<void> _preparar() async {
    await _pessoaViewModel.commands.buscar(widget.pessoaId);
    await _avaliacaoViewModel.commands.prepararPara(widget.pessoaId);

    if (!mounted) return;
    setState(() {
      // Reabrir uma avaliação já feita começa das notas anteriores.
      _criterios = _avaliacaoViewModel.state.avaliacaoAtual.value?.criterios ??
          CriteriosPopularidade.inicial();
      _preparando = false;
    });
  }

  Future<void> _salvar() async {
    final resultado = await _avaliacaoViewModel.commands.salvar(
      pessoaId: widget.pessoaId,
      criterios: _criterios,
    );

    if (!mounted) return;

    resultado.fold(
      onSuccess: (avaliacao) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Avaliação registrada: ${avaliacao.pontuacaoTotal} pontos de '
              'Nível Lenda.',
            ),
          ),
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
      appBar: AppBar(title: const Text('Avaliar pessoa')),
      body: _preparando
          ? const Center(child: CircularProgressIndicator())
          : Watch((context) {
              final state = _avaliacaoViewModel.state;
              final pessoa = _pessoaViewModel.state.selecionada.value;

              if (state.ehAutoavaliacao.value) {
                return const _BloqueioAutoavaliacao();
              }

              final salvando = state.carregando.value;
              final editando = state.editando.value;
              final erro = state.erro.value;

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  SecaoTitulo(
                    titulo: pessoa?.nome ?? 'Pessoa',
                    subtitulo: editando
                        ? 'Você já avaliou esta pessoa — alterando sua nota.'
                        : 'Dê de 1 a 5 estrelas em cada critério.',
                  ),
                  const SizedBox(height: 16),
                  _PlacarAtual(pontos: _criterios.nivelLenda),
                  const SizedBox(height: 20),
                  ..._criterios.items.map(
                    (item) => CriterioEstrelas(
                      nome: item.nome,
                      descricao: item.descricao,
                      valor: item.getValue(_criterios),
                      onChanged: (novoValor) => setState(() {
                        _criterios = item.setValue(_criterios, novoValor);
                      }),
                    ),
                  ),
                  if (erro != null) ...[
                    const SizedBox(height: 16),
                    AvisoErro(mensagem: erro),
                  ],
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: salvando ? null : _salvar,
                    icon: salvando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.star_rounded),
                    label: Text(
                      editando ? 'Salvar alteração' : 'Registrar avaliação',
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }),
    );
  }
}

/// Mostra a soma das notas enquanto o usuário mexe nos sliders (item 11).
class _PlacarAtual extends StatelessWidget {
  final int pontos;

  const _PlacarAtual({required this.pontos});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            MedalhaNivelLenda(pontos: pontos, tamanho: 64),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Nível Lenda desta avaliação',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Varia de 15 a 75 pontos, somando os 15 critérios.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BloqueioAutoavaliacao extends StatelessWidget {
  const _BloqueioAutoavaliacao();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block_rounded, size: 80, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'Essa pessoa é você',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'O PiramidGame não permite que ninguém avalie a si próprio. '
              'Deixe essa parte para o resto do campus.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
