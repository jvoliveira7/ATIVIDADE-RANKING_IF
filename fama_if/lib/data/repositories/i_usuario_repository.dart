import '../../core/typedefs/types_defs.dart';
import '../../domain/models/usuario.dart';

/// Contrato do repositório de usuários (item 4.2).
abstract interface class IUsuarioRepository {
  Future<UsuarioResult> salvar(Usuario usuario);
  Future<UsuarioResult> buscarPorUid(String uid);
  Future<VoidResult> vincularPessoa({
    required String uid,
    required String pessoaId,
  });
}
