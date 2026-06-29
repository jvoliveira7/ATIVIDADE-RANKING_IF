import 'package:equatable/equatable.dart';

import '../../core/failure/failure.dart';

/// Representa as notas (1 a 5 estrelas) dos 15 critérios de popularidade
/// definidos na especificação (item 7).
///
/// Cada critério é um campo nomeado e tipado (em vez de um Map ou List
/// genérico), seguindo o mesmo estilo do professor na entidade `Character`
/// (campos como `level`, `attack`, `health`). Isso dá segurança de tipos e
/// deixa o código mais legível: `criterios.resenha` em vez de
/// `criterios['resenha']`.
///
/// Para evitar repetir 15 blocos de UI praticamente idênticos na tela de
/// cadastro, a classe também expõe [items], uma lista de metadados
/// ([CriterioInfo]) que a UI pode percorrer em um único loop. Cada item
/// carrega o nome, a descrição, e funções de leitura/escrita (getter/setter)
/// que apontam de volta para o campo nomeado correspondente.
class CriteriosPopularidade extends Equatable {
  final int resenha;
  final int presencaVip;
  final int aura;
  final int modoParceiro;
  final int carismaNatural;
  final int humorDeMilhoes;
  final int energiaDeGrupo;
  final int criatividadeCaotica;
  final int modoAtleta;
  final int talentoDePalco;
  final int dripEscolar;
  final int coracaoDeDorama;
  final int queridinhoDosProfessores;
  final int cerebroTurbo;
  final int caosControlado;

  const CriteriosPopularidade({
    required this.resenha,
    required this.presencaVip,
    required this.aura,
    required this.modoParceiro,
    required this.carismaNatural,
    required this.humorDeMilhoes,
    required this.energiaDeGrupo,
    required this.criatividadeCaotica,
    required this.modoAtleta,
    required this.talentoDePalco,
    required this.dripEscolar,
    required this.coracaoDeDorama,
    required this.queridinhoDosProfessores,
    required this.cerebroTurbo,
    required this.caosControlado,
  });

  /// Cria uma instância com todas as notas no valor mínimo (1 estrela).
  /// Útil como valor inicial no formulário de cadastro.
  factory CriteriosPopularidade.inicial() => const CriteriosPopularidade(
        resenha: 1,
        presencaVip: 1,
        aura: 1,
        modoParceiro: 1,
        carismaNatural: 1,
        humorDeMilhoes: 1,
        energiaDeGrupo: 1,
        criatividadeCaotica: 1,
        modoAtleta: 1,
        talentoDePalco: 1,
        dripEscolar: 1,
        coracaoDeDorama: 1,
        queridinhoDosProfessores: 1,
        cerebroTurbo: 1,
        caosControlado: 1,
      );

  /// Valida que todas as 15 notas estão entre 1 e 5 estrelas.
  /// Lança [InvalidStarRatingFailure] caso alguma nota esteja fora do intervalo.
  void validar() {
    for (final item in items) {
      final nota = item.getValue(this);
      if (nota < 1 || nota > 5) {
        throw InvalidStarRatingFailure(
          'O critério "${item.nome}" deve ter nota entre 1 e 5 estrelas.',
        );
      }
    }
  }

  /// Soma das 15 notas. Resultado entre 15 e 75 pontos.
  /// É o que a especificação chama de "Nível Lenda" (item 8).
  int get nivelLenda => items.fold(0, (soma, item) => soma + item.getValue(this));

  /// Cria uma cópia com alguns valores substituídos.
  CriteriosPopularidade copyWith({
    int? resenha,
    int? presencaVip,
    int? aura,
    int? modoParceiro,
    int? carismaNatural,
    int? humorDeMilhoes,
    int? energiaDeGrupo,
    int? criatividadeCaotica,
    int? modoAtleta,
    int? talentoDePalco,
    int? dripEscolar,
    int? coracaoDeDorama,
    int? queridinhoDosProfessores,
    int? cerebroTurbo,
    int? caosControlado,
  }) {
    return CriteriosPopularidade(
      resenha: resenha ?? this.resenha,
      presencaVip: presencaVip ?? this.presencaVip,
      aura: aura ?? this.aura,
      modoParceiro: modoParceiro ?? this.modoParceiro,
      carismaNatural: carismaNatural ?? this.carismaNatural,
      humorDeMilhoes: humorDeMilhoes ?? this.humorDeMilhoes,
      energiaDeGrupo: energiaDeGrupo ?? this.energiaDeGrupo,
      criatividadeCaotica: criatividadeCaotica ?? this.criatividadeCaotica,
      modoAtleta: modoAtleta ?? this.modoAtleta,
      talentoDePalco: talentoDePalco ?? this.talentoDePalco,
      dripEscolar: dripEscolar ?? this.dripEscolar,
      coracaoDeDorama: coracaoDeDorama ?? this.coracaoDeDorama,
      queridinhoDosProfessores:
          queridinhoDosProfessores ?? this.queridinhoDosProfessores,
      cerebroTurbo: cerebroTurbo ?? this.cerebroTurbo,
      caosControlado: caosControlado ?? this.caosControlado,
    );
  }

  /// Lista de metadados dos 15 critérios, na mesma ordem da especificação
  /// (item 7). A UI percorre essa lista para gerar os 15 campos de
  /// star rating sem repetir código, e usa `setValue` para criar uma nova
  /// instância atualizada (a classe é imutável).
  List<CriterioInfo> get items => [
        CriterioInfo(
          nome: 'Resenha',
          descricao:
              'Mede o quanto o aluno anima a turma, puxa conversa e contribui '
              'para deixar o ambiente mais descontraído.',
          getValue: (c) => c.resenha,
          setValue: (c, v) => c.copyWith(resenha: v),
        ),
        CriterioInfo(
          nome: 'Presença VIP',
          descricao:
              'Avalia o quanto o aluno é lembrado, percebido ou reconhecido '
              'pelos colegas no dia a dia da turma.',
          getValue: (c) => c.presencaVip,
          setValue: (c, v) => c.copyWith(presencaVip: v),
        ),
        CriterioInfo(
          nome: 'Aura',
          descricao:
              'Representa a energia geral do aluno: presença, estilo, jeito '
              'de ser e impacto que causa no ambiente.',
          getValue: (c) => c.aura,
          setValue: (c, v) => c.copyWith(aura: v),
        ),
        CriterioInfo(
          nome: 'Modo Parceiro',
          descricao:
              'Mede o quanto o aluno ajuda os colegas, colabora nas '
              'atividades e demonstra espírito de parceria.',
          getValue: (c) => c.modoParceiro,
          setValue: (c, v) => c.copyWith(modoParceiro: v),
        ),
        CriterioInfo(
          nome: 'Carisma Natural',
          descricao:
              'Avalia a facilidade do aluno para socializar, conversar e '
              'criar boas relações com os colegas.',
          getValue: (c) => c.carismaNatural,
          setValue: (c, v) => c.copyWith(carismaNatural: v),
        ),
        CriterioInfo(
          nome: 'Humor de Milhões',
          descricao:
              'Representa o quanto o aluno contribui com bom humor, '
              'brincadeiras saudáveis e momentos divertidos.',
          getValue: (c) => c.humorDeMilhoes,
          setValue: (c, v) => c.copyWith(humorDeMilhoes: v),
        ),
        CriterioInfo(
          nome: 'Energia de Grupo',
          descricao:
              'Mede a participação do aluno em trabalhos, eventos, jogos, '
              'dinâmicas e atividades coletivas da turma.',
          getValue: (c) => c.energiaDeGrupo,
          setValue: (c, v) => c.copyWith(energiaDeGrupo: v),
        ),
        CriterioInfo(
          nome: 'Criatividade Caótica',
          descricao:
              'Avalia a capacidade do aluno de ter ideias diferentes, '
              'soluções inesperadas e comentários geniais.',
          getValue: (c) => c.criatividadeCaotica,
          setValue: (c, v) => c.copyWith(criatividadeCaotica: v),
        ),
        CriterioInfo(
          nome: 'Modo Atleta',
          descricao:
              'Representa a aptidão esportiva, a disposição física e o '
              'espírito competitivo saudável do aluno.',
          getValue: (c) => c.modoAtleta,
          setValue: (c, v) => c.copyWith(modoAtleta: v),
        ),
        CriterioInfo(
          nome: 'Talento de Palco',
          descricao:
              'Mede a aptidão artística do aluno, como música, canto, '
              'instrumentos, dança, ritmo ou presença em apresentações.',
          getValue: (c) => c.talentoDePalco,
          setValue: (c, v) => c.copyWith(talentoDePalco: v),
        ),
        CriterioInfo(
          nome: 'Drip Escolar',
          descricao:
              'Avalia o estilo pessoal do aluno, considerando roupas, '
              'tênis, cabelo, acessórios e presença visual.',
          getValue: (c) => c.dripEscolar,
          setValue: (c, v) => c.copyWith(dripEscolar: v),
        ),
        CriterioInfo(
          nome: 'Coração de Dorama',
          descricao:
              'Representa o carisma afetivo, a gentileza e aquela vibe de '
              'protagonista romântico, sem expor relacionamentos reais.',
          getValue: (c) => c.coracaoDeDorama,
          setValue: (c, v) => c.copyWith(coracaoDeDorama: v),
        ),
        CriterioInfo(
          nome: 'Queridinho dos Professores',
          descricao:
              'Mede a boa relação do aluno com os professores, considerando '
              'respeito, participação, educação e responsabilidade.',
          getValue: (c) => c.queridinhoDosProfessores,
          setValue: (c, v) => c.copyWith(queridinhoDosProfessores: v),
        ),
        CriterioInfo(
          nome: 'Cérebro Turbo',
          descricao:
              'Avalia o desempenho nos estudos, a facilidade para aprender, '
              'resolver problemas e se destacar academicamente.',
          getValue: (c) => c.cerebroTurbo,
          setValue: (c, v) => c.copyWith(cerebroTurbo: v),
        ),
        CriterioInfo(
          nome: 'Caos Controlado',
          descricao:
              'Mede o quanto o aluno é bagunceiro, zoeiro ou imprevisível, '
              'mas ainda dentro dos limites do respeito e da convivência '
              'saudável.',
          getValue: (c) => c.caosControlado,
          setValue: (c, v) => c.copyWith(caosControlado: v),
        ),
      ];

  @override
  List<Object?> get props => [
        resenha,
        presencaVip,
        aura,
        modoParceiro,
        carismaNatural,
        humorDeMilhoes,
        energiaDeGrupo,
        criatividadeCaotica,
        modoAtleta,
        talentoDePalco,
        dripEscolar,
        coracaoDeDorama,
        queridinhoDosProfessores,
        cerebroTurbo,
        caosControlado,
      ];
}

/// Metadados de um critério individual, usados pela UI para montar a
/// listagem de 15 star ratings em um único loop, sem repetir código.
class CriterioInfo {
  final String nome;
  final String descricao;
  final int Function(CriteriosPopularidade criterios) getValue;
  final CriteriosPopularidade Function(CriteriosPopularidade criterios, int novoValor)
      setValue;

  CriterioInfo({
    required this.nome,
    required this.descricao,
    required this.getValue,
    required this.setValue,
  });
}
