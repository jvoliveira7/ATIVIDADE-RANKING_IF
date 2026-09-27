import 'package:signals_flutter/signals_flutter.dart';

import '../../domain/models/pessoa.dart';

/// Estado reativo das telas de pessoas (item 4.5).
class PessoaState {
  /// Pessoas cadastradas, exibidas na listagem (item 14.6).
  final pessoas = signal<List<Pessoa>>([]);

  /// Pessoa aberta nos detalhes ou em edição (itens 14.7 e 14.8).
  final selecionada = signal<Pessoa?>(null);

  final carregando = signal<bool>(false);
  final erro = signal<String?>(null);

  late final listaVazia = computed(() => pessoas.value.isEmpty);

  void limparErro() => erro.value = null;
}
