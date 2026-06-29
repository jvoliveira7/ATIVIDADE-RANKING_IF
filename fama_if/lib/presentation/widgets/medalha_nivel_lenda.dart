import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Selo circular de medalha — o elemento de assinatura visual do app,
/// usado consistentemente para representar o Nível Lenda em: card da
/// listagem, tela de detalhes e ranking.
///
/// O anel duplo remete a medalhas de papelão de eventos escolares; a
/// cor do anel externo muda conforme a posição no ranking (ouro/prata/
/// bronze para os 3 primeiros), e usa o dourado padrão fora do ranking.
class MedalhaNivelLenda extends StatelessWidget {
  final int pontos;
  final int? posicao;
  final double tamanho;

  const MedalhaNivelLenda({
    super.key,
    required this.pontos,
    this.posicao,
    this.tamanho = 56,
  });

  Color get _corAnel {
    switch (posicao) {
      case 1:
        return AppTheme.corOuro;
      case 2:
        return AppTheme.corPrata;
      case 3:
        return AppTheme.corBronze;
      default:
        return AppTheme.ouroLenda;
    }
  }

  @override
  Widget build(BuildContext context) {
    final corAnel = _corAnel;
    final corTexto = Theme.of(context).colorScheme.onSecondaryContainer;

    return SizedBox(
      width: tamanho,
      height: tamanho,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Anel externo (a "medalha" em si)
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: corAnel, width: tamanho * 0.07),
            ),
          ),
          // Disco interno
          Container(
            width: tamanho * 0.78,
            height: tamanho * 0.78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: corAnel.withValues(alpha: 0.18),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$pontos',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: tamanho * 0.32,
                  color: corTexto,
                  height: 1,
                ),
              ),
              Text(
                'pts',
                style: TextStyle(
                  fontSize: tamanho * 0.14,
                  fontWeight: FontWeight.w600,
                  color: corTexto.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
