import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/models/item_ranking.dart';
import 'pessoa_card.dart';

/// Lista ordenada de um ranking, compartilhada pelas telas de ranking pessoal
/// (item 12) e global (item 13).
///
/// A diferença entre os dois aparece no rodapé de cada linha: no global, cada
/// pessoa mostra a média e quantas avaliações entraram na conta; no pessoal,
/// a nota é única e exata, então não há o que informar.
class ListaRanking extends StatelessWidget {
  final List<ItemRanking> itens;
  final bool mostrarQuantidade;
  final void Function(ItemRanking item)? onTap;
  final Future<void> Function()? onRefresh;

  const ListaRanking({
    super.key,
    required this.itens,
    this.mostrarQuantidade = false,
    this.onTap,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final formatador = NumberFormat('#,##0.0', 'pt_BR');

    final lista = ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: itens.length,
      itemBuilder: (context, index) {
        final item = itens[index];
        final posicao = index + 1;

        return PessoaCard(
          pessoa: item.pessoa,
          posicao: posicao,
          pontos: item.pontuacaoInteira,
          rodape: mostrarQuantidade
              ? '${formatador.format(item.pontuacao)} pontos · '
                  '${item.quantidadeAvaliacoes} '
                  '${item.quantidadeAvaliacoes == 1 ? "avaliação" : "avaliações"}'
              : null,
          onTap: onTap == null ? null : () => onTap!(item),
        );
      },
    );

    if (onRefresh == null) return lista;
    return RefreshIndicator(onRefresh: onRefresh!, child: lista);
  }
}

/// Estado vazio compartilhado pelas telas de ranking.
class RankingVazio extends StatelessWidget {
  final String titulo;
  final String descricao;

  const RankingVazio({
    super.key,
    required this.titulo,
    required this.descricao,
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
            Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: colorScheme.outline,
            ),
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
          ],
        ),
      ),
    );
  }
}
