import 'package:equatable/equatable.dart';

import '../../core/failure/failure.dart';
import 'curso.dart';

/// Pessoa cadastrada para receber avaliações (item 7 da especificação).
///
/// Não se confunde com o usuário autenticado (item 5): uma pessoa pode existir
/// sem possuir conta no app, e [usuarioUid] só é preenchido quando ela
/// corresponde a um usuário. É esse vínculo que permite bloquear a
/// autoavaliação (itens 9 e 14.12).
///
/// Diferente da entidade `Aluno` da primeira parte, a Pessoa **não** carrega
/// notas: os 15 critérios agora vivem em [Avaliacao], porque cada usuário
/// atribui as suas próprias notas para a mesma pessoa.
class Pessoa extends Equatable {
  final String id;
  final String nome;
  final String apelido;
  final Curso curso;
  final int turmaAno;
  final DateTime dataNascimento;

  /// uid do usuário que cadastrou esta pessoa (campo `criadoPor` do item 15).
  final String criadoPor;

  /// uid do usuário que *é* esta pessoa, quando existe tal vínculo.
  final String? usuarioUid;

  Pessoa({
    required this.id,
    required this.nome,
    required this.apelido,
    required this.curso,
    required this.turmaAno,
    required this.dataNascimento,
    required this.criadoPor,
    this.usuarioUid,
  }) {
    _validate();
  }

  void _validate() {
    if (nome.trim().isEmpty) {
      throw InputFailure('O nome da pessoa é obrigatório.');
    }
    if (turmaAno < 1998 || turmaAno > 2026) {
      throw InvalidYearFailure();
    }
  }

  /// Verdadeiro quando esta pessoa é o próprio usuário informado — usado para
  /// impedir que alguém avalie a si próprio (item 16).
  bool ehOProprioUsuario(String uid) => usuarioUid != null && usuarioUid == uid;

  Pessoa copyWith({
    String? id,
    String? nome,
    String? apelido,
    Curso? curso,
    int? turmaAno,
    DateTime? dataNascimento,
    String? criadoPor,
    String? usuarioUid,
  }) {
    return Pessoa(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      apelido: apelido ?? this.apelido,
      curso: curso ?? this.curso,
      turmaAno: turmaAno ?? this.turmaAno,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      criadoPor: criadoPor ?? this.criadoPor,
      usuarioUid: usuarioUid ?? this.usuarioUid,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nome,
        apelido,
        curso,
        turmaAno,
        dataNascimento,
        criadoPor,
        usuarioUid,
      ];

  @override
  String toString() => 'Pessoa(id: $id, nome: $nome, apelido: $apelido, '
      'curso: ${curso.displayName}, turmaAno: $turmaAno)';
}
