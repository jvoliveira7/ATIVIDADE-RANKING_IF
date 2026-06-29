import 'package:flutter/material.dart';

/// Widget reutilizável para dar nota (1 a 5) em um critério de
/// popularidade (item 7 da especificação). Usado em loop pela tela de
/// cadastro/edição, uma vez para cada um dos 15 critérios.
///
/// Usa [Slider.adaptive] com `divisions: 4`, o que restringe o usuário a
/// exatamente os valores inteiros 1, 2, 3, 4 ou 5 — não é possível
/// selecionar um valor fora desse intervalo.
class CriterioSlider extends StatelessWidget {
  final String nome;
  final String descricao;
  final int valor;
  final ValueChanged<int> onChanged;

  const CriterioSlider({
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
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  nome,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$valor ★',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
          Text(
            descricao,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.55),
                ),
          ),
          Slider(
            value: valor.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            label: valor.toString(),
            onChanged: (novoValor) => onChanged(novoValor.round()),
          ),
        ],
      ),
    );
  }
}
