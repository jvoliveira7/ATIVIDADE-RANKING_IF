import 'package:signals_flutter/signals_flutter.dart';

import '../../core/failure/failure.dart';
import '../../domain/models/aluno.dart';

/// Mantém o estado observável das telas relacionadas a Aluno.
/// A UI "observa" (via `Watch` ou `effect`) estes signals e é
/// reconstruída automaticamente sempre que algum deles muda — sem
/// precisar de `setState` manual.
class AlunoStateViewModel {
  /// Lista de alunos exibida na tela Home (item 10.2).
  final alunos = signal<List<Aluno>>([]);

  /// Lista de alunos já ordenada por Nível Lenda, exibida na tela de
  /// Ranking (item 10.6).
  final ranking = signal<List<Aluno>>([]);

  /// Aluno atualmente selecionado (tela de Detalhes ou edição).
  final alunoSelecionado = signal<Aluno?>(null);

  /// Indica se alguma operação está em andamento (mostra spinner na UI).
  final carregando = signal<bool>(false);

  /// Última falha ocorrida, para exibir mensagem de erro na UI.
  final erro = signal<Failure?>(null);

  /// Computed: verdadeiro quando não há nenhum aluno cadastrado.
  /// Usado para mostrar um "empty state" na tela Home.
  late final listaVazia = computed(() => alunos.value.isEmpty);

  void limparErro() => erro.value = null;
}
