import 'package:equatable/equatable.dart';

import 'pessoa.dart';

/// Uma linha de ranking, usada tanto pelo ranking pessoal (item 12) quanto
/// pelo global (item 13).
///
/// No ranking pessoal [pontuacao] é a nota que o usuário autenticado deu e
/// [quantidadeAvaliacoes] vale 1. No global, [pontuacao] é a **média** das
/// avaliações recebidas e [quantidadeAvaliacoes] diz quantas pessoas avaliaram.
class ItemRanking extends Equatable {
  final Pessoa pessoa;
  final double pontuacao;
  final int quantidadeAvaliacoes;

  const ItemRanking({
    required this.pessoa,
    required this.pontuacao,
    required this.quantidadeAvaliacoes,
  });

  /// Pontuação arredondada, para quando a exibição pede um inteiro
  /// (caso do ranking pessoal, em que a nota é sempre exata).
  int get pontuacaoInteira => pontuacao.round();

  @override
  List<Object?> get props => [pessoa, pontuacao, quantidadeAvaliacoes];

  @override
  String toString() => 'ItemRanking(${pessoa.nome}: $pontuacao pontos, '
      '$quantidadeAvaliacoes avaliações)';
}
