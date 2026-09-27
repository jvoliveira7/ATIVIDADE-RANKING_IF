import 'package:signals_flutter/signals_flutter.dart';

import '../../domain/models/item_ranking.dart';

/// Estado reativo das duas telas de ranking (item 4.5).
class RankingState {
  /// "Na minha opinião..." — só as avaliações do usuário (item 12).
  final pessoal = signal<List<ItemRanking>>([]);

  /// "Na opinião dos usuários do app..." — média de todos (item 13).
  final global = signal<List<ItemRanking>>([]);

  final carregando = signal<bool>(false);
  final erro = signal<String?>(null);

  void limparErro() => erro.value = null;
}
