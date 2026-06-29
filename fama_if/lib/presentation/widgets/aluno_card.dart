import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/aluno.dart';
import 'medalha_nivel_lenda.dart';

/// Card que representa um aluno, no conceito de "crachá de campus":
/// uma faixa colorida lateral identifica o curso, e o Nível Lenda é
/// exibido como medalha (elemento de assinatura do app). Reutilizado
/// na tela Home (listagem, item 10.2) e na tela de Ranking (item 9),
/// onde também recebe a posição (`posicao`) para destacar o pódio.
class AlunoCard extends StatelessWidget {
  final Aluno aluno;
  final int? posicao;
  final VoidCallback? onTap;

  const AlunoCard({
    super.key,
    required this.aluno,
    this.posicao,
    this.onTap,
  });

  Color get _corFaixa =>
      AppTheme.corPorCurso[aluno.curso.displayName] ?? AppTheme.roxoRecreio;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final corFaixa = _corFaixa;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.08)),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Faixa lateral colorida (identidade do curso)
                  Container(
                    width: 8,
                    decoration: BoxDecoration(
                      color: corFaixa,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(18),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                      child: Row(
                        children: [
                          if (posicao != null) ...[
                            _PosicaoNumero(posicao: posicao!),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  aluno.nome,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '"${aluno.apelido}"',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontStyle: FontStyle.italic,
                                        color: colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                _SeloCurso(
                                  curso: aluno.curso.displayName,
                                  ano: aluno.turmaAno,
                                  cor: corFaixa,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          MedalhaNivelLenda(
                            pontos: aluno.nivelLenda,
                            posicao: posicao,
                            tamanho: 52,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PosicaoNumero extends StatelessWidget {
  final int posicao;

  const _PosicaoNumero({required this.posicao});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$posicao°',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
          ),
    );
  }
}

class _SeloCurso extends StatelessWidget {
  final String curso;
  final int ano;
  final Color cor;

  const _SeloCurso({required this.curso, required this.ano, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$curso · $ano',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: cor,
        ),
      ),
    );
  }
}
