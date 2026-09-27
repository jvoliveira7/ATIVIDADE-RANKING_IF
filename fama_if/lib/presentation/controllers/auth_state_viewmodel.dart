import 'package:signals_flutter/signals_flutter.dart';

import '../../domain/models/usuario.dart';

/// Situação da sessão conhecida pelo app.
enum AuthStatus {
  /// Ainda não se sabe: o Firebase não terminou de restaurar a sessão.
  /// É o estado em que a splash segura a navegação (item 18).
  desconhecido,
  autenticado,
  naoAutenticado,
}

/// Estado reativo da autenticação (item 4.5).
class AuthState {
  final usuario = signal<Usuario?>(null);
  final status = signal<AuthStatus>(AuthStatus.desconhecido);
  final mensagem = signal<String?>(null);
  final carregando = signal<bool>(false);

  bool get autenticado => status.value == AuthStatus.autenticado;

  /// Usuário logado que ainda não tem uma pessoa vinculada. Acontece no
  /// primeiro acesso, principalmente via Google, e é o que leva à tela de
  /// completar perfil — sem esse vínculo não há como barrar autoavaliação.
  late final precisaCompletarPerfil = computed(() {
    final atual = usuario.value;
    return status.value == AuthStatus.autenticado &&
        atual != null &&
        (atual.pessoaId == null || atual.pessoaId!.isEmpty);
  });

  void definirAutenticado(Usuario novoUsuario) {
    usuario.value = novoUsuario;
    status.value = AuthStatus.autenticado;
  }

  void definirNaoAutenticado({String? msg}) {
    usuario.value = null;
    status.value = AuthStatus.naoAutenticado;
    if (msg != null) mensagem.value = msg;
  }

  void definirMensagem(String msg) => mensagem.value = msg;

  void limparMensagem() => mensagem.value = null;
}
