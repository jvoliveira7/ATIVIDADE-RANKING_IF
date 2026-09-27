import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:fama_if/data/repositories/ranking_repository_impl.dart';
import 'package:fama_if/data/services/firestore_avaliacao_service.dart';
import 'package:fama_if/data/services/firestore_pessoa_service.dart';
import 'package:fama_if/domain/models/avaliacao.dart';
import 'package:fama_if/domain/models/item_ranking.dart';
import 'package:fama_if/domain/usecases/ranking_usecases_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestorePessoaService pessoaService;
  late FirestoreAvaliacaoService avaliacaoService;
  late RankingRepositoryImpl rankingRepository;
  late FakeAuthRepository authRepository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    pessoaService = FirestorePessoaService(firestore: firestore);
    avaliacaoService = FirestoreAvaliacaoService(firestore: firestore);
    rankingRepository = RankingRepositoryImpl(
      pessoaService: pessoaService,
      avaliacaoService: avaliacaoService,
    );
    authRepository = FakeAuthRepository();
  });

  Future<void> cadastrarPessoa(String id, String nome) async {
    await pessoaService.salvar(pessoaFake(id: id, nome: nome));
  }

  Future<void> avaliar({
    required String avaliadorUid,
    required String pessoaId,
    required int total,
  }) async {
    await avaliacaoService.salvar(
      Avaliacao.nova(
        avaliadorUid: avaliadorUid,
        pessoaId: pessoaId,
        criterios: criteriosComTotal(total),
      ),
    );
  }

  group('Ranking pessoal (item 12)', () {
    test('ordena da maior para a menor pontuação dada pelo usuário', () async {
      authRepository.entrarComo(usuarioFake(uid: 'avaliador-1'));

      await cadastrarPessoa('p1', 'Ana Clara');
      await cadastrarPessoa('p2', 'João Pedro');
      await cadastrarPessoa('p3', 'Maria Eduarda');

      await avaliar(avaliadorUid: 'avaliador-1', pessoaId: 'p2', total: 58);
      await avaliar(avaliadorUid: 'avaliador-1', pessoaId: 'p1', total: 68);
      await avaliar(avaliadorUid: 'avaliador-1', pessoaId: 'p3', total: 54);

      final useCase = CalcularRankingPessoalUseCase(
        repository: rankingRepository,
        authRepository: authRepository,
      );

      final resultado = await useCase(());
      final ranking = resultado.successValueOrNull!;

      expect(ranking.map((i) => i.pessoa.nome), [
        'Ana Clara',
        'João Pedro',
        'Maria Eduarda',
      ]);
      expect(ranking.map((i) => i.pontuacaoInteira), [68, 58, 54]);
    });

    test('ignora as avaliações feitas pelos outros usuários', () async {
      authRepository.entrarComo(usuarioFake(uid: 'avaliador-1'));

      await cadastrarPessoa('p1', 'Ana Clara');
      await cadastrarPessoa('p2', 'João Pedro');

      await avaliar(avaliadorUid: 'avaliador-1', pessoaId: 'p1', total: 40);
      await avaliar(avaliadorUid: 'outro-usuario', pessoaId: 'p2', total: 75);

      final useCase = CalcularRankingPessoalUseCase(
        repository: rankingRepository,
        authRepository: authRepository,
      );

      final ranking = (await useCase(())).successValueOrNull!;

      expect(ranking, hasLength(1));
      expect(ranking.single.pessoa.nome, 'Ana Clara');
    });

    test('exige usuário autenticado', () async {
      final useCase = CalcularRankingPessoalUseCase(
        repository: rankingRepository,
        authRepository: authRepository,
      );

      final resultado = await useCase(());

      expect(resultado.isFailure, isTrue);
    });
  });

  group('Ranking global (item 13)', () {
    test('usa a média das avaliações recebidas e informa a quantidade',
        () async {
      await cadastrarPessoa('p1', 'Ana');

      // Exemplo da especificação: 60, 70 e 65 resultam em 65 pontos.
      await avaliar(avaliadorUid: 'u1', pessoaId: 'p1', total: 60);
      await avaliar(avaliadorUid: 'u2', pessoaId: 'p1', total: 70);
      await avaliar(avaliadorUid: 'u3', pessoaId: 'p1', total: 65);

      final useCase =
          CalcularRankingGlobalUseCase(repository: rankingRepository);

      final ranking = (await useCase(())).successValueOrNull!;

      expect(ranking, hasLength(1));
      expect(ranking.single.pontuacao, 65.0);
      expect(ranking.single.quantidadeAvaliacoes, 3);
    });

    test('ordena pela média, não pela soma', () async {
      await cadastrarPessoa('p1', 'Muitas avaliações medianas');
      await cadastrarPessoa('p2', 'Uma avaliação altíssima');

      await avaliar(avaliadorUid: 'u1', pessoaId: 'p1', total: 40);
      await avaliar(avaliadorUid: 'u2', pessoaId: 'p1', total: 40);
      await avaliar(avaliadorUid: 'u3', pessoaId: 'p1', total: 40);
      await avaliar(avaliadorUid: 'u1', pessoaId: 'p2', total: 75);

      final useCase =
          CalcularRankingGlobalUseCase(repository: rankingRepository);

      final ranking = (await useCase(())).successValueOrNull!;

      expect(ranking.first.pessoa.nome, 'Uma avaliação altíssima');
      expect(ranking.first.pontuacao, 75.0);
      expect(ranking.last.pontuacao, 40.0);
    });

    test('deixa de fora quem ainda não recebeu avaliação', () async {
      await cadastrarPessoa('p1', 'Avaliada');
      await cadastrarPessoa('p2', 'Ainda sem avaliação');

      await avaliar(avaliadorUid: 'u1', pessoaId: 'p1', total: 50);

      final useCase =
          CalcularRankingGlobalUseCase(repository: rankingRepository);

      final ranking = (await useCase(())).successValueOrNull!;

      expect(ranking.map((ItemRanking i) => i.pessoa.nome), ['Avaliada']);
    });
  });
}
