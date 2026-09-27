import 'package:cloud_firestore/cloud_firestore.dart';

import 'avaliacao.dart';
import 'criterios_popularidade.dart';

/// Conversão entre [Avaliacao] e o documento da coleção `avaliacoes`.
///
/// As 15 notas são gravadas como campos planos no documento, com os nomes
/// exatos listados no item 15 da especificação — repare que lá o critério
/// "Queridinho dos Professores" aparece como `queridinhoProfessores`, sem o
/// "dos" que a entidade usa internamente.
///
/// `pontuacaoTotal` é gravado junto mesmo sendo derivado das notas: o item 23
/// pede que a pontuação seja calculada automaticamente, e tê-la no documento
/// permite ordenar e somar no servidor sem reprocessar os 15 campos.
class AvaliacaoMapper {
  const AvaliacaoMapper._();

  static Map<String, dynamic> toFirestore(Avaliacao avaliacao) {
    final c = avaliacao.criterios;
    return {
      'avaliadorUid': avaliacao.avaliadorUid,
      'pessoaId': avaliacao.pessoaId,
      'resenha': c.resenha,
      'presencaVip': c.presencaVip,
      'aura': c.aura,
      'modoParceiro': c.modoParceiro,
      'carismaNatural': c.carismaNatural,
      'humorDeMilhoes': c.humorDeMilhoes,
      'energiaDeGrupo': c.energiaDeGrupo,
      'criatividadeCaotica': c.criatividadeCaotica,
      'modoAtleta': c.modoAtleta,
      'talentoDePalco': c.talentoDePalco,
      'dripEscolar': c.dripEscolar,
      'coracaoDeDorama': c.coracaoDeDorama,
      'queridinhoProfessores': c.queridinhoDosProfessores,
      'cerebroTurbo': c.cerebroTurbo,
      'caosControlado': c.caosControlado,
      'pontuacaoTotal': avaliacao.pontuacaoTotal,
      'dataAvaliacao': Timestamp.fromDate(avaliacao.dataAvaliacao),
    };
  }

  static Avaliacao fromFirestore(String id, Map<String, dynamic> dados) {
    return Avaliacao(
      id: id,
      avaliadorUid: dados['avaliadorUid'] as String? ?? '',
      pessoaId: dados['pessoaId'] as String? ?? '',
      criterios: CriteriosPopularidade(
        resenha: _nota(dados['resenha']),
        presencaVip: _nota(dados['presencaVip']),
        aura: _nota(dados['aura']),
        modoParceiro: _nota(dados['modoParceiro']),
        carismaNatural: _nota(dados['carismaNatural']),
        humorDeMilhoes: _nota(dados['humorDeMilhoes']),
        energiaDeGrupo: _nota(dados['energiaDeGrupo']),
        criatividadeCaotica: _nota(dados['criatividadeCaotica']),
        modoAtleta: _nota(dados['modoAtleta']),
        talentoDePalco: _nota(dados['talentoDePalco']),
        dripEscolar: _nota(dados['dripEscolar']),
        coracaoDeDorama: _nota(dados['coracaoDeDorama']),
        queridinhoDosProfessores: _nota(dados['queridinhoProfessores']),
        cerebroTurbo: _nota(dados['cerebroTurbo']),
        caosControlado: _nota(dados['caosControlado']),
      ),
      dataAvaliacao: _paraData(dados['dataAvaliacao']),
    );
  }

  static int _nota(Object? valor) => (valor as num?)?.toInt() ?? 1;

  static DateTime _paraData(Object? valor) {
    if (valor is Timestamp) return valor.toDate();
    if (valor is DateTime) return valor;
    if (valor is String) return DateTime.parse(valor);
    return DateTime.now();
  }
}
