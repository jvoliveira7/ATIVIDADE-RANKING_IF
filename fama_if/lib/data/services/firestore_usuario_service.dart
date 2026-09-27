import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/usuario.dart';
import '../../domain/models/usuario_mapper.dart';
import 'i_usuario_service.dart';

/// Acesso à coleção `usuarios` do Firestore.
final class FirestoreUsuarioService implements IUsuarioService {
  static const String colecao = 'usuarios';

  final FirebaseFirestore _firestore;

  FirestoreUsuarioService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usuarios =>
      _firestore.collection(colecao);

  @override
  Future<UsuarioResult> salvar(Usuario usuario) async {
    try {
      // merge para não apagar o `pessoaId` já gravado quando o usuário entra
      // de novo e o perfil é regravado a partir dos dados do Firebase Auth.
      await _usuarios.doc(usuario.uid).set(
            UsuarioMapper.toFirestore(usuario),
            SetOptions(merge: true),
          );
      return Success(usuario);
    } catch (e) {
      return Error(FirestoreFailure('Erro ao salvar usuário: $e'));
    }
  }

  @override
  Future<UsuarioResult> buscarPorUid(String uid) async {
    try {
      final doc = await _usuarios.doc(uid).get();
      final dados = doc.data();
      if (!doc.exists || dados == null) {
        return Error(EmptyResultFailure('Perfil de usuário não encontrado.'));
      }
      return Success(UsuarioMapper.fromFirestore(doc.id, dados));
    } catch (e) {
      return Error(FirestoreFailure('Erro ao buscar usuário: $e'));
    }
  }

  @override
  Future<VoidResult> vincularPessoa({
    required String uid,
    required String pessoaId,
  }) async {
    try {
      await _usuarios.doc(uid).set(
        {'pessoaId': pessoaId},
        SetOptions(merge: true),
      );
      return const Success(null);
    } catch (e) {
      return Error(FirestoreFailure('Erro ao vincular pessoa ao usuário: $e'));
    }
  }
}
