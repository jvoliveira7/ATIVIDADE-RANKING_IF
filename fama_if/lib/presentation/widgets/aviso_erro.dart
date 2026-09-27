import 'package:flutter/material.dart';

/// Faixa de erro padronizada, usada nas telas de autenticação e nos
/// formulários para mostrar ao usuário a falha vinda da camada de domínio
/// (item 19: erros tratados e informados).
class AvisoErro extends StatelessWidget {
  final String mensagem;

  const AvisoErro({super.key, required this.mensagem});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensagem,
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
