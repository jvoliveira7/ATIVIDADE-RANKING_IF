import 'package:signals_flutter/signals_flutter.dart';

import '../../core/typedefs/types_defs.dart';
import '../../domain/models/usuario.dart';

/// Contrato do repositório de autenticação (item 4.2).
abstract interface class IAuthRepository {
  Signal<Usuario?> get usuarioAtualSignal;
  Usuario? get usuarioAtual;

  Future<void> inicializarSessao();
  Future<UsuarioResult> entrarComEmail(String email, String senha);
  Future<UsuarioResult> cadastrarComEmail({
    required String nome,
    required String email,
    required String senha,
  });
  Future<UsuarioResult> entrarComGoogle();
  Future<VoidResult> sair();
}
