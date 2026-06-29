import 'package:equatable/equatable.dart';

import '../../core/failure/failure.dart';
import 'criterios_popularidade.dart';
import 'curso.dart';

/// Entidade principal do domínio: representa um aluno cadastrado no app,
/// com seus dados básicos (item 5 da especificação) e suas notas nos
/// 15 critérios de popularidade (item 7).
///
/// Segue o mesmo estilo da entidade `Character` do projeto de referência:
/// imutável, valida seus próprios dados no construtor (`_validate`), expõe
/// `copyWith` para criar cópias modificadas, e usa `Equatable` para
/// comparação por valor (duas instâncias com os mesmos dados são iguais).
class Aluno extends Equatable {
  final String id;
  final String nome;
  final Curso curso;
  final int turmaAno;
  final String apelido;
  final DateTime dataNascimento;
  final CriteriosPopularidade criterios;

  Aluno({
    required this.id,
    required this.nome,
    required this.curso,
    required this.turmaAno,
    required this.apelido,
    required this.dataNascimento,
    required this.criterios,
  }) {
    _validate();
  }

  /// Valida as regras gerais do app (item 15 da especificação):
  /// nome obrigatório e turma/ano dentro do intervalo permitido.
  /// As notas dos critérios são validadas separadamente em
  /// [CriteriosPopularidade.validar].
  void _validate() {
    if (nome.trim().isEmpty) {
      throw InputFailure('O nome do aluno é obrigatório.');
    }
    if (turmaAno < 1998 || turmaAno > 2026) {
      throw InvalidYearFailure();
    }
    criterios.validar();
  }

  /// Pontuação total do aluno (soma dos 15 critérios).
  /// Chamado de "Nível Lenda" na especificação (item 8), varia de 15 a 75.
  int get nivelLenda => criterios.nivelLenda;

  Aluno copyWith({
    String? id,
    String? nome,
    Curso? curso,
    int? turmaAno,
    String? apelido,
    DateTime? dataNascimento,
    CriteriosPopularidade? criterios,
  }) {
    return Aluno(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      curso: curso ?? this.curso,
      turmaAno: turmaAno ?? this.turmaAno,
      apelido: apelido ?? this.apelido,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      criterios: criterios ?? this.criterios,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nome,
        curso,
        turmaAno,
        apelido,
        dataNascimento,
        criterios,
      ];

  @override
  String toString() {
    return 'Aluno('
        'id: $id, '
        'nome: $nome, '
        'curso: ${curso.displayName}, '
        'turmaAno: $turmaAno, '
        'apelido: $apelido, '
        'nivelLenda: $nivelLenda'
        ')';
  }
}
