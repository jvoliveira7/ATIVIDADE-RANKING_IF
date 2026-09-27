import '../../core/typedefs/types_defs.dart';
import '../../domain/models/usuario.dart';

/// Contrato do serviço da coleção `usuarios` (itens 3.2 e 15).
///
/// O Firebase Authentication guarda as credenciais; o Firestore guarda o
/// perfil do usuário (nome, foto, provider) e o vínculo com a pessoa avaliável.
abstract interface class IUsuarioService {
  Future<UsuarioResult> salvar(Usuario usuario);
  Future<UsuarioResult> buscarPorUid(String uid);

  /// Registra qual pessoa corresponde a este usuário (item 5).
  Future<VoidResult> vincularPessoa({
    required String uid,
    required String pessoaId,
  });
}
