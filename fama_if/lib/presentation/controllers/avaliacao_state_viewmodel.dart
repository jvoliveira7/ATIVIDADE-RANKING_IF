import 'package:signals_flutter/signals_flutter.dart';

import '../../domain/models/avaliacao.dart';

/// Estado reativo da tela de avaliação (item 4.5).
class AvaliacaoState {
  /// Avaliação que o usuário já deu para a pessoa aberta, se houver.
  /// Quando existe, a tela entra em modo de alteração (item 14.11).
  final avaliacaoAtual = signal<Avaliacao?>(null);

  /// Avaliações feitas pelo usuário autenticado.
  final minhasAvaliacoes = signal<List<Avaliacao>>([]);

  /// Verdadeiro quando a pessoa aberta é o próprio usuário (item 14.12).
  final ehAutoavaliacao = signal<bool>(false);

  final carregando = signal<bool>(false);
  final erro = signal<String?>(null);

  late final editando = computed(() => avaliacaoAtual.value != null);

  void limparErro() => erro.value = null;

  void limpar() {
    avaliacaoAtual.value = null;
    ehAutoavaliacao.value = false;
    erro.value = null;
  }
}
