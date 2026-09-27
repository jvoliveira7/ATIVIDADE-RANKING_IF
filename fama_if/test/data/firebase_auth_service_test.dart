import 'package:fama_if/core/failure/failure.dart';
import 'package:fama_if/data/services/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

/// Testes do serviço de autenticação (item 3.1) usando um Firebase Auth de
/// mentira, sem tocar no projeto real.
void main() {
  test('cadastro com e-mail e senha cria a sessão com o nome informado',
      () async {
    final service = FirebaseAuthService(firebaseAuth: MockFirebaseAuth());

    final resultado = await service.cadastrarComEmail(
      nome: 'João Victor',
      email: 'joao@ifpr.edu.br',
      senha: 'senha123',
    );

    final usuario = resultado.successValueOrNull!;
    expect(usuario.nome, 'João Victor');
    expect(usuario.email, 'joao@ifpr.edu.br');
    expect(service.usuarioAtual, isNotNull);
  });

  test('login com e-mail e senha popula o signal da sessão', () async {
    final mock = MockFirebaseAuth(
      mockUser: MockUser(
        uid: 'uid-1',
        email: 'joao@ifpr.edu.br',
        displayName: 'João Victor',
      ),
    );
    final service = FirebaseAuthService(firebaseAuth: mock);

    final resultado =
        await service.entrarComEmail('joao@ifpr.edu.br', 'senha123');

    expect(resultado.isSuccess, isTrue);
    expect(service.usuarioAtualSignal.value?.uid, 'uid-1');
  });

  group('Erros do Firebase viram falhas do domínio (item 19)', () {
    Failure traduzir(String codigo) =>
        FirebaseAuthService.traduzirErro(FirebaseAuthException(code: codigo));

    test('credenciais incorretas', () {
      expect(traduzir('invalid-credential'), isA<InvalidCredentialsFailure>());
      expect(traduzir('wrong-password'), isA<InvalidCredentialsFailure>());
      expect(traduzir('user-not-found'), isA<InvalidCredentialsFailure>());
    });

    test('e-mail já cadastrado', () {
      expect(traduzir('email-already-in-use'), isA<EmailAlreadyInUseFailure>());
    });

    test('senha fraca', () {
      expect(traduzir('weak-password'), isA<WeakPasswordFailure>());
    });

    test('código desconhecido cai na falha genérica de autenticação', () {
      expect(traduzir('algo-que-nao-mapeamos'), isA<AuthFailure>());
    });
  });

  test('logout encerra a sessão', () async {
    final mock = MockFirebaseAuth(signedIn: true);
    final service = FirebaseAuthService(firebaseAuth: mock);

    final resultado = await service.sair();

    expect(resultado.isSuccess, isTrue);
    expect(service.usuarioAtual, isNull);
  });

  test('sessão persistida é restaurada na inicialização (item 14.3)',
      () async {
    // `signedIn: true` representa o app reabrindo com sessão já gravada.
    final mock = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'uid-1', email: 'joao@ifpr.edu.br'),
    );
    final service = FirebaseAuthService(firebaseAuth: mock);

    await service.inicializarSessao();

    expect(service.usuarioAtual?.uid, 'uid-1');
  });
}
