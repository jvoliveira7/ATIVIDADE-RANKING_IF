import 'package:equatable/equatable.dart';

import '../../core/failure/failure.dart';
import 'criterios_popularidade.dart';

/// Avaliação que um usuário faz de uma pessoa (itens 9 e 16 da especificação).
///
/// Identifica sempre quem avaliou ([avaliadorUid]) e quem foi avaliado
/// ([pessoaId]), e guarda as notas dos 15 critérios. A pontuação total é
/// derivada das notas, nunca informada por fora (item 23).
class Avaliacao extends Equatable {
  final String id;
  final String avaliadorUid;
  final String pessoaId;
  final CriteriosPopularidade criterios;
  final DateTime dataAvaliacao;

  Avaliacao({
    required this.id,
    required this.avaliadorUid,
    required this.pessoaId,
    required this.criterios,
    required this.dataAvaliacao,
  }) {
    _validate();
  }

  /// Cria uma avaliação já com o id determinístico correspondente ao par.
  factory Avaliacao.nova({
    required String avaliadorUid,
    required String pessoaId,
    required CriteriosPopularidade criterios,
    DateTime? dataAvaliacao,
  }) {
    return Avaliacao(
      id: idPara(avaliadorUid: avaliadorUid, pessoaId: pessoaId),
      avaliadorUid: avaliadorUid,
      pessoaId: pessoaId,
      criterios: criterios,
      dataAvaliacao: dataAvaliacao ?? DateTime.now(),
    );
  }

  /// Identificador derivado do par avaliador + pessoa.
  ///
  /// É o que garante a regra "usuário + pessoa avaliada = uma avaliação"
  /// (item 16) na própria chave do documento: uma segunda avaliação do mesmo
  /// par sobrescreve a anterior em vez de criar um registro novo, sem precisar
  /// de consulta prévia nem de transação.
  static String idPara({
    required String avaliadorUid,
    required String pessoaId,
  }) =>
      '${avaliadorUid}_$pessoaId';

  /// Soma das 15 notas — o "Nível Lenda" desta avaliação (item 11).
  int get pontuacaoTotal => criterios.nivelLenda;

  void _validate() {
    if (avaliadorUid.trim().isEmpty) {
      throw UnauthenticatedFailure();
    }
    if (pessoaId.trim().isEmpty) {
      throw InputFailure('A avaliação precisa identificar a pessoa avaliada.');
    }
    criterios.validar();
  }

  Avaliacao copyWith({
    CriteriosPopularidade? criterios,
    DateTime? dataAvaliacao,
  }) {
    return Avaliacao(
      id: id,
      avaliadorUid: avaliadorUid,
      pessoaId: pessoaId,
      criterios: criterios ?? this.criterios,
      dataAvaliacao: dataAvaliacao ?? this.dataAvaliacao,
    );
  }

  @override
  List<Object?> get props => [
        id,
        avaliadorUid,
        pessoaId,
        criterios,
        dataAvaliacao,
      ];

  @override
  String toString() => 'Avaliacao(avaliador: $avaliadorUid, pessoa: $pessoaId, '
      'pontuacaoTotal: $pontuacaoTotal)';
}
