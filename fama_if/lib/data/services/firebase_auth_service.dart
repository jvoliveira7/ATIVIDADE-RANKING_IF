import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/usuario.dart';
import 'i_auth_service.dart';

/// Serviço de autenticação sobre o Firebase Authentication (itens 3.1 e 4.1).
///
/// Cobre as duas formas exigidas pela especificação: e-mail/senha e conta
/// Google. O `FirebaseAuth` é injetável para permitir testes com dublês.
final class FirebaseAuthService implements IAuthService {
  final fb.FirebaseAuth _firebaseAuth;
  final Signal<Usuario?> _usuarioAtual = signal<Usuario?>(null);

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
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();

      final conta = await googleSignIn.authenticate();
      final idToken = conta.authentication.idToken;
      if (idToken == null) {
        return Error(AuthFailure('O Google não devolveu um token válido.'));
      }

      final credencial = fb.GoogleAuthProvider.credential(idToken: idToken);
      final resultado = await _firebaseAuth.signInWithCredential(credencial);
      final user = resultado.user;
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
      return Error(traduzirErro(e));
    } catch (e) {
      return Error(AuthFailure('Falha no login com Google: $e'));
    }
  }

  @override
  Future<VoidResult> sair() async {
    try {
      // Desconectar do Google também, senão o próximo login com Google entra
      // direto na última conta sem oferecer a escolha. A falha aqui é
      // ignorada de propósito: quem entrou por e-mail nunca inicializou o
      // Google, e isso não pode impedir o logout de acontecer.
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}

      await _firebaseAuth.signOut();
      _usuarioAtual.value = null;
      return const Success(null);
    } catch (e) {
      return Error(AuthFailure('Falha ao sair: $e'));
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
