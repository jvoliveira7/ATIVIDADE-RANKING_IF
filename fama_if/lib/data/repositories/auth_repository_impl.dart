import 'package:signals_flutter/signals_flutter.dart';

import '../../core/typedefs/types_defs.dart';
import '../../domain/models/usuario.dart';
import '../services/i_auth_service.dart';
import '../services/i_local_storage_service.dart';
import 'i_auth_repository.dart';

/// Repositório de autenticação: intermedia o acesso ao [IAuthService] e
/// mantém o cache local do usuário em dia (item 4.2).
///
/// O cache existe apenas para a interface mostrar nome e foto sem esperar a
/// rede; a validade da sessão continua vindo do Firebase (item 3.3).
final class AuthRepositoryImpl implements IAuthRepository {
  final IAuthService _authService;
  final ILocalStorageService _localStorage;

  AuthRepositoryImpl({
    required IAuthService authService,
    required ILocalStorageService localStorage,
  })  : _authService = authService,
        _localStorage = localStorage;

  @override
  Signal<Usuario?> get usuarioAtualSignal => _authService.usuarioAtualSignal;

  @override
  Usuario? get usuarioAtual => _authService.usuarioAtual;

  @override
  Future<void> inicializarSessao() => _authService.inicializarSessao();

  @override
  Future<UsuarioResult> entrarComEmail(String email, String senha) async {
    final resultado = await _authService.entrarComEmail(email, senha);
    await _atualizarCache(resultado);
    return resultado;
  }

  @override
  Future<UsuarioResult> cadastrarComEmail({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final resultado = await _authService.cadastrarComEmail(
      nome: nome,
      email: email,
      senha: senha,
    );
    await _atualizarCache(resultado);
    return resultado;
  }

  @override
  Future<UsuarioResult> entrarComGoogle() async {
    final resultado = await _authService.entrarComGoogle();
    await _atualizarCache(resultado);
    return resultado;
  }

  @override
  Future<VoidResult> sair() async {
    final resultado = await _authService.sair();
    await _localStorage.limparCacheUsuario();
    return resultado;
  }

  Future<void> _atualizarCache(UsuarioResult resultado) async {
    final usuario = resultado.successValueOrNull;
    if (usuario != null) await _localStorage.salvarCacheUsuario(usuario);
  }
}
