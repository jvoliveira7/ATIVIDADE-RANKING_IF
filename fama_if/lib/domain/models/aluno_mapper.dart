import 'aluno.dart';
import 'criterios_popularidade.dart';
import 'curso.dart';

/// Converte instâncias de [Aluno] para `Map<String, dynamic>` e vice-versa.
/// É essa representação em Map que será convertida para JSON e salva no
/// SharedPreferences (item 14 da especificação).
class AlunoMapper {
  static Map<String, dynamic> toMap(Aluno aluno) {
    return {
      'id': aluno.id,
      'nome': aluno.nome,
      'curso': aluno.curso.name,
      'turmaAno': aluno.turmaAno,
      'apelido': aluno.apelido,
      'dataNascimento': aluno.dataNascimento.toIso8601String(),
      'criterios': _criteriosToMap(aluno.criterios),
    };
  }

  static Aluno fromMap(Map<String, dynamic> map) {
    return Aluno(
      id: map['id'] as String,
      nome: map['nome'] as String,
      curso: Curso.values.byName(map['curso'] as String),
      turmaAno: map['turmaAno'] as int,
      apelido: map['apelido'] as String,
      dataNascimento: DateTime.parse(map['dataNascimento'] as String),
      criterios: _criteriosFromMap(map['criterios'] as Map<String, dynamic>),
    );
  }

  static Map<String, dynamic> _criteriosToMap(CriteriosPopularidade c) {
    return {
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
      'queridinhoDosProfessores': c.queridinhoDosProfessores,
      'cerebroTurbo': c.cerebroTurbo,
      'caosControlado': c.caosControlado,
    };
  }

  static CriteriosPopularidade _criteriosFromMap(Map<String, dynamic> map) {
    return CriteriosPopularidade(
      resenha: map['resenha'] as int,
      presencaVip: map['presencaVip'] as int,
      aura: map['aura'] as int,
      modoParceiro: map['modoParceiro'] as int,
      carismaNatural: map['carismaNatural'] as int,
      humorDeMilhoes: map['humorDeMilhoes'] as int,
      energiaDeGrupo: map['energiaDeGrupo'] as int,
      criatividadeCaotica: map['criatividadeCaotica'] as int,
      modoAtleta: map['modoAtleta'] as int,
      talentoDePalco: map['talentoDePalco'] as int,
      dripEscolar: map['dripEscolar'] as int,
      coracaoDeDorama: map['coracaoDeDorama'] as int,
      queridinhoDosProfessores: map['queridinhoDosProfessores'] as int,
      cerebroTurbo: map['cerebroTurbo'] as int,
      caosControlado: map['caosControlado'] as int,
    );
  }
}
