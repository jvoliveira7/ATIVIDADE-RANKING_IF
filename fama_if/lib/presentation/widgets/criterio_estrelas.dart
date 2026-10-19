import 'package:flutter/material.dart';

/// Dá nota de 1 a 5 estrelas em um critério de popularidade (item 10).
/// Toda nota é um inteiro de 1 a 5, e tocar na estrela escolhe a nota.
class CriterioEstrelas extends StatelessWidget {
  final String nome;
  final String descricao;
  final int valor;
  final ValueChanged<int> onChanged;

  const CriterioEstrelas({
    super.key,
    required this.nome,
    required this.descricao,
    required this.valor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(nome, style: Theme.of(context).textTheme.titleSmall),
          Text(
            descricao,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.55),
                ),
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(5, (i) {
              final nota = i + 1;
              final ativa = nota <= valor;
              return Semantics(
                button: true,
                label: '$nota ${nota == 1 ? 'estrela' : 'estrelas'}',
                child: IconButton(
                  onPressed: () => onChanged(nota),
                  tooltip: '$nota',
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    ativa ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 34,
                    color: ativa
                        ? Colors.amber
                        : colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}