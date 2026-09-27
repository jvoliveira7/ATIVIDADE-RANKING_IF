import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:fama_if/core/failure/failure.dart';
import 'package:fama_if/data/repositories/avaliacao_repository_impl.dart';
import 'package:fama_if/data/repositories/pessoa_repository_impl.dart';
import 'package:fama_if/data/services/firestore_avaliacao_service.dart';
import 'package:fama_if/data/services/firestore_pessoa_service.dart';
import 'package:fama_if/domain/usecases/avaliacao_usecases_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestorePessoaService pessoaService;
  late FirestoreAvaliacaoService avaliacaoService;
  late PessoaRepositoryImpl pessoaRepository;
  late AvaliacaoRepositoryImpl avaliacaoRepository;
  late FakeAuthRepository authRepository;
  late RegistrarAvaliacaoUseCase registrar;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    pessoaService = FirestorePessoaService(firestore: firestore);
    avaliacaoService = FirestoreAvaliacaoService(firestore: firestore);
    pessoaRepository = PessoaRepositoryImpl(service: pessoaService);
    avaliacaoRepository = AvaliacaoRepositoryImpl(service: avaliacaoService);
    authRepository = FakeAuthRepository();

    registrar = RegistrarAvaliacaoUseCase(
      authRepository: authRepository,
      pessoaRepository: pessoaRepository,
      avaliacaoRepository: avaliacaoRepository,
    );
  });

  group('Registrar avaliação (itens 14.10 e 16)', () {
    test('grava a avaliação com a pontuação somada dos 15 critérios',
        () async {
      authRepository.entrarComo(usuarioFake(uid: 'avaliador'));
      await pessoaService.salvar(pessoaFake(id: 'p1'));

      final resultado = await registrar((
        pessoaId: 'p1',
        criterios: criteriosComTotal(58),
      ));

      final avaliacao = resultado.successValueOrNull!;
      expect(avaliacao.pontuacaoTotal, 58);
      expect(avaliacao.avaliadorUid, 'avaliador');
      expect(avaliacao.pessoaId, 'p1');
    });

    test('impede autoavaliação quando a pessoa é o próprio usuário', () async {
      authRepository.entrarComo(usuarioFake(uid: 'avaliador'));
      await pessoaService.salvar(
        pessoaFake(id: 'p1', usuarioUid: 'avaliador'),
      );

      final resultado = await registrar((
        pessoaId: 'p1',
        criterios: criteriosComTotal(75),
      ));

      expect(resultado.isFailure, isTrue);
      expect(resultado.failureValueOrNull, isA<SelfEvaluationFailure>());
    });

    test('recusa avaliação sem usuário autenticado', () async {
      await pessoaService.salvar(pessoaFake(id: 'p1'));

      final resultado = await registrar((
        pessoaId: 'p1',
        criterios: criteriosComTotal(40),
      ));

      expect(resultado.failureValueOrNull, isA<UnauthenticatedFailure>());
    });

    test('recusa nota fora do intervalo de 1 a 5 estrelas', () async {
      authRepository.entrarComo(usuarioFake(uid: 'avaliador'));
      await pessoaService.salvar(pessoaFake(id: 'p1'));

      final criteriosInvalidos =
          criteriosComTotal(40).copyWith(resenha: 9);

      final resultado = await registrar((
        pessoaId: 'p1',
        criterios: criteriosInvalidos,
      ));

      expect(resultado.failureValueOrNull, isA<InvalidStarRatingFailure>());
    });

    test('recusa avaliação de pessoa inexistente', () async {
      authRepository.entrarComo(usuarioFake(uid: 'avaliador'));

      final resultado = await registrar((
        pessoaId: 'nao-existe',
        criterios: criteriosComTotal(40),
      ));

      expect(resultado.failureValueOrNull, isA<PersonNotFoundFailure>());
    });

    test(
      'cada usuário mantém uma única avaliação por pessoa: avaliar de novo '
      'substitui a anterior',
      () async {
        authRepository.entrarComo(usuarioFake(uid: 'avaliador'));
        await pessoaService.salvar(pessoaFake(id: 'p1'));

        await registrar((pessoaId: 'p1', criterios: criteriosComTotal(30)));
        await registrar((pessoaId: 'p1', criterios: criteriosComTotal(70)));

        final todas = await avaliacaoService.buscarTodas();
        final avaliacoes = todas.successValueOrNull!;

        expect(avaliacoes, hasLength(1));
        expect(avaliacoes.single.pontuacaoTotal, 70);
      },
    );

    test('usuários diferentes avaliam a mesma pessoa de forma independente',
        () async {
      await pessoaService.salvar(pessoaFake(id: 'p1'));

      authRepository.entrarComo(usuarioFake(uid: 'ana'));
      await registrar((pessoaId: 'p1', criterios: criteriosComTotal(30)));

      authRepository.entrarComo(usuarioFake(uid: 'bruno'));
      await registrar((pessoaId: 'p1', criterios: criteriosComTotal(70)));

      final avaliacoes =
          (await avaliacaoService.buscarTodas()).successValueOrNull!;

      expect(avaliacoes, hasLength(2));
    });
  });

  group('Alterar avaliação (item 14.11)', () {
    test('falha quando ainda não existe avaliação daquele usuário', () async {
      authRepository.entrarComo(usuarioFake(uid: 'avaliador'));
      await pessoaService.salvar(pessoaFake(id: 'p1'));

      final alterar = AlterarAvaliacaoUseCase(
        authRepository: authRepository,
        pessoaRepository: pessoaRepository,
        avaliacaoRepository: avaliacaoRepository,
      );

      final resultado =
          await alterar((pessoaId: 'p1', criterios: criteriosComTotal(50)));

      expect(resultado.failureValueOrNull, isA<EvaluationNotFoundFailure>());
    });

    test('atualiza as notas da avaliação existente', () async {
      authRepository.entrarComo(usuarioFake(uid: 'avaliador'));
      await pessoaService.salvar(pessoaFake(id: 'p1'));
      await registrar((pessoaId: 'p1', criterios: criteriosComTotal(30)));

      final alterar = AlterarAvaliacaoUseCase(
        authRepository: authRepository,
        pessoaRepository: pessoaRepository,
        avaliacaoRepository: avaliacaoRepository,
      );

      final resultado =
          await alterar((pessoaId: 'p1', criterios: criteriosComTotal(65)));

      expect(resultado.successValueOrNull!.pontuacaoTotal, 65);
    });
  });

  group('Verificar autoavaliação (item 14.12)', () {
    test('responde verdadeiro para a pessoa vinculada ao usuário', () async {
      authRepository.entrarComo(usuarioFake(uid: 'avaliador'));
      await pessoaService.salvar(
        pessoaFake(id: 'eu', usuarioUid: 'avaliador'),
      );
      await pessoaService.salvar(pessoaFake(id: 'outra'));

      final verificar = VerificarAutoavaliacaoUseCase(
        authRepository: authRepository,
        pessoaRepository: pessoaRepository,
      );

      expect((await verificar((id: 'eu'))).successValueOrNull, isTrue);
      expect((await verificar((id: 'outra'))).successValueOrNull, isFalse);
    });
  });
}
