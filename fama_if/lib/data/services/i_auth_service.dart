import 'package:signals_flutter/signals_flutter.dart';

import '../../core/typedefs/types_defs.dart';
import '../../domain/models/usuario.dart';

/// Contrato do serviço de autenticação (item 4.1 da especificação).
///
/// É a única peça do app que conhece o Firebase Authentication. Quem determina
/// se a sessão é válida é sempre este serviço, nunca o armazenamento local
/// (item 3.3).
abstract interface class IAuthService {
  /// Usuário autenticado no momento, de forma reativa. Emite `null` quando
  /// não há sessão. É alimentado pelo `authStateChanges()` do Firebase, então
  /// reflete também logins e logouts disparados de fora do app.
  Signal<Usuario?> get usuarioAtualSignal;

  /// Leitura direta do usuário autenticado, sem observar o signal.
  Usuario? get usuarioAtual;

  /// Aguarda o Firebase restaurar (ou descartar) a sessão persistida.
  /// Chamado uma vez na inicialização, antes de decidir a rota inicial.
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
