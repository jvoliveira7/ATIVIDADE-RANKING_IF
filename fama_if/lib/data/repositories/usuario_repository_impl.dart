import '../../core/typedefs/types_defs.dart';
import '../../domain/models/usuario.dart';
import '../services/i_usuario_service.dart';
import 'i_usuario_repository.dart';

/// Repositório do perfil do usuário no Firestore (item 4.2).
final class UsuarioRepositoryImpl implements IUsuarioRepository {
  final IUsuarioService _service;

  UsuarioRepositoryImpl({required IUsuarioService service})
      : _service = service;

  @override
  Future<UsuarioResult> salvar(Usuario usuario) => _service.salvar(usuario);

  @override
  Future<UsuarioResult> buscarPorUid(String uid) => _service.buscarPorUid(uid);

  @override
  Future<VoidResult> vincularPessoa({
    required String uid,
    required String pessoaId,
  }) =>
      _service.vincularPessoa(uid: uid, pessoaId: pessoaId);
}
