import 'package:cloud_firestore/cloud_firestore.dart';

import 'curso.dart';
import 'pessoa.dart';

/// Conversão entre [Pessoa] e o documento da coleção `pessoas`.
///
/// Os nomes dos campos seguem o item 15 da especificação. O id não é gravado
/// dentro do documento: ele já é a própria chave do documento no Firestore.
class PessoaMapper {
  const PessoaMapper._();

  static Map<String, dynamic> toFirestore(Pessoa pessoa) {
    return {
      'nome': pessoa.nome,
      'apelido': pessoa.apelido,
      'curso': pessoa.curso.name,
      'turma': pessoa.turmaAno,
      'dataNascimento': Timestamp.fromDate(pessoa.dataNascimento),
      'criadoPor': pessoa.criadoPor,
      'usuarioUid': pessoa.usuarioUid,
    };
  }

  static Pessoa fromFirestore(String id, Map<String, dynamic> dados) {
    return Pessoa(
      id: id,
      nome: dados['nome'] as String? ?? '',
      apelido: dados['apelido'] as String? ?? '',
      curso: Curso.values.byName(dados['curso'] as String? ?? Curso.info.name),
      turmaAno: (dados['turma'] as num?)?.toInt() ?? 1998,
      dataNascimento: _paraData(dados['dataNascimento']),
      criadoPor: dados['criadoPor'] as String? ?? '',
      usuarioUid: dados['usuarioUid'] as String?,
    );
  }

  /// O Firestore devolve `Timestamp`, mas dados gravados por outra via (ou por
  /// um dublê de teste) podem chegar como String ISO-8601.
  static DateTime _paraData(Object? valor) {
    if (valor is Timestamp) return valor.toDate();
    if (valor is DateTime) return valor;
    if (valor is String) return DateTime.parse(valor);
    return DateTime(1998);
  }
}
