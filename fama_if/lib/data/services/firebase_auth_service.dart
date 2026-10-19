import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/usuario.dart';
import 'i_auth_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Serviço de autenticação sobre o Firebase Authentication (itens 3.1 e 4.1).
///
/// Cobre as duas formas exigidas pela especificação: e-mail/senha e conta
/// Google. O `FirebaseAuth` é injetável para permitir testes com dublês.
final class FirebaseAuthService implements IAuthService {
  final fb.FirebaseAuth _firebaseAuth;
  final Signal<Usuario?> _usuarioAtual = signal<Usuario?>(null);

  // google_sign_in 7.x: `initialize()` deve ser chamado e aguardado UMA única
  // vez por execução do app. Guardamos o Future para reaproveitá-lo em todo
  // login com Google (inclusive depois de um logout).
  Future<void>? _inicializacaoGoogle;

  FirebaseAuthService({fb.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance {
    // A sessão do app acompanha o Firebase: qualquer login, logout ou
    // revogação de token reflete aqui sem o app precisar perguntar.
    _firebaseAuth.authStateChanges().listen((user) {
      _usuarioAtual.value = user == null ? null : _paraUsuario(user);
    });
  }

  @override
  Signal<Usuario?> get usuarioAtualSignal => _usuarioAtual;

  @override
  Usuario? get usuarioAtual => _usuarioAtual.value;

  @override
  Future<void> inicializarSessao() async {
    // A persistência do Firebase é carregada de forma assíncrona: sem esperar
    // o primeiro evento, o app decidiria a rota inicial achando que ninguém
    // está logado e jogaria o usuário na tela de login por engano.
    final user = await _firebaseAuth.authStateChanges().first;
    _usuarioAtual.value = user == null ? null : _paraUsuario(user);
  }

  @override
  Future<UsuarioResult> entrarComEmail(String email, String senha) async {
    try {
      final credencial = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
      final user = credencial.user;
      if (user == null) return Error(AuthFailure());

      final usuario = _paraUsuario(user);
      _usuarioAtual.value = usuario;
      return Success(usuario);
    } on fb.FirebaseAuthException catch (e) {
      return Error(traduzirErro(e));
    } catch (e) {
      return Error(AuthFailure('Falha ao entrar: $e'));
    }
  }

  @override
  Future<UsuarioResult> cadastrarComEmail({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      final credencial = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
      final user = credencial.user;
      if (user == null) return Error(AuthFailure());

      await user.updateDisplayName(nome.trim());
      // `updateDisplayName` não atualiza a instância já em memória.
      await user.reload();

      final usuario = _paraUsuario(_firebaseAuth.currentUser ?? user)
          .copyWith(nome: nome.trim());
      _usuarioAtual.value = usuario;
      return Success(usuario);
    } on fb.FirebaseAuthException catch (e) {
      return Error(traduzirErro(e));
    } catch (e) {
      return Error(AuthFailure('Falha ao cadastrar: $e'));
    }
  }
@override
Future<UsuarioResult> entrarComGoogle() async {
  try {
    final fb.User? user;

    if (kIsWeb) {
      // Na web o google_sign_in 7.x não tem authenticate(): usa o popup do
      // próprio Firebase Auth.
      final resultado =
          await _firebaseAuth.signInWithPopup(fb.GoogleAuthProvider());
      user = resultado.user;
    } else {
      await _garantirGoogleInicializado();
      final conta = await GoogleSignIn.instance.authenticate();
      final idToken = conta.authentication.idToken;
      if (idToken == null) {
        return Error(AuthFailure('O Google não devolveu um token válido.'));
      }
      final credencial = fb.GoogleAuthProvider.credential(idToken: idToken);
      user = (await _firebaseAuth.signInWithCredential(credencial)).user;
    }

    if (user == null) return Error(AuthFailure());

    final usuario = _paraUsuario(user);
    _usuarioAtual.value = usuario;
    return Success(usuario);
  } on GoogleSignInException catch (e) {
    if (e.code == GoogleSignInExceptionCode.canceled) {
      return Error(AuthCancelledFailure());
    }
    return Error(AuthFailure('Falha no login com Google: ${e.description}'));
  } on fb.FirebaseAuthException catch (e) {
    // Fechar o popup não é erro: é o usuário desistindo.
    if (e.code == 'popup-closed-by-user' ||
        e.code == 'cancelled-popup-request') {
      return Error(AuthCancelledFailure());
    }
    return Error(traduzirErro(e));
  } catch (e) {
    return Error(AuthFailure('Falha no login com Google: $e'));
  }
}

  @override
Future<VoidResult> sair() async {
  try {
    await _firebaseAuth.signOut();
    _usuarioAtual.value = null;
  } catch (e) {
    return Error(AuthFailure('Falha ao sair: $e'));
  }

  
  if (!kIsWeb) {
    try {
      await _garantirGoogleInicializado();
      await GoogleSignIn.instance.signOut().timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  return const Success(null);
}

  Future<void> _garantirGoogleInicializado() {
    return _inicializacaoGoogle ??= _inicializarGoogle();
  }

  Future<void> _inicializarGoogle() async {
    try {
          await GoogleSignIn.instance.initialize(
        serverClientId:
            '232556044672-o39h6mildkvnp23dieknfg4ajjnid934.apps.googleusercontent.com',
      );
    } catch (_) {
      // Se falhou, libera para uma nova tentativa no próximo login.
      _inicializacaoGoogle = null;
      rethrow;
    }
  }

  Usuario _paraUsuario(fb.User user) {
    return Usuario(
      uid: user.uid,
      nome: user.displayName ?? '',
      email: user.email ?? '',
      foto: user.photoURL,
      provider: user.providerData.any((p) => p.providerId == 'google.com')
          ? AuthProvider.google
          : AuthProvider.emailSenha,
    );
  }

  /// Converte os códigos do Firebase em falhas do domínio, para a UI mostrar
  /// uma mensagem em português em vez do texto cru do SDK (item 19).
  ///
  /// Público para poder ser testado sem precisar de um Firebase que saiba
  /// simular cada código de erro.
  static Failure traduzirErro(fb.FirebaseAuthException e) {
    return switch (e.code) {
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' =>
        InvalidCredentialsFailure(),
      'email-already-in-use' => EmailAlreadyInUseFailure(),
      'weak-password' => WeakPasswordFailure(),
      'invalid-email' => InputFailure('E-mail inválido.'),
      'user-disabled' => AuthFailure('Esta conta foi desativada.'),
      'too-many-requests' =>
        AuthFailure('Muitas tentativas. Tente novamente em alguns minutos.'),
      'network-request-failed' =>
        AuthFailure('Sem conexão. Verifique sua internet.'),
      _ => AuthFailure(e.message),
    };
  }
}
