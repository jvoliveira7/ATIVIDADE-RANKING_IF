import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/pessoa.dart';
import '../../domain/models/pessoa_mapper.dart';
import 'i_pessoa_service.dart';

/// Acesso à coleção `pessoas` do Firestore (itens 3.2 e 15).
final class FirestorePessoaService implements IPessoaService {
  static const String colecao = 'pessoas';

  final FirebaseFirestore _firestore;

  FirestorePessoaService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _pessoas =>
      _firestore.collection(colecao);

  @override
  Future<PessoaResult> salvar(Pessoa pessoa) async {
    try {
      await _pessoas.doc(pessoa.id).set(PessoaMapper.toFirestore(pessoa));
      return Success(pessoa);
    } catch (e) {
      return Error(FirestoreFailure('Erro ao cadastrar pessoa: $e'));
    }
  }

  @override
  Future<PessoaResult> atualizar(Pessoa pessoa) async {
    try {
      await _pessoas.doc(pessoa.id).update(PessoaMapper.toFirestore(pessoa));
      return Success(pessoa);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') return Error(PersonNotFoundFailure());
      return Error(FirestoreFailure('Erro ao alterar pessoa: ${e.message}'));
    } catch (e) {
      return Error(FirestoreFailure('Erro ao alterar pessoa: $e'));
    }
  }

  @override
  Future<VoidResult> remover(String id) async {
    try {
      await _pessoas.doc(id).delete();
      return const Success(null);
    } catch (e) {
      return Error(FirestoreFailure('Erro ao remover pessoa: $e'));
    }
  }

  @override
  Future<ListPessoaResult> buscarTodas() async {
    try {
      final snapshot = await _pessoas.orderBy('nome').get();
      final pessoas = snapshot.docs
          .map((doc) => PessoaMapper.fromFirestore(doc.id, doc.data()))
          .toList();
      return Success(pessoas);
    } catch (e) {
      return Error(FirestoreFailure('Erro ao buscar pessoas: $e'));
    }
  }

  @override
  Future<PessoaResult> buscarPorId(String id) async {
    try {
      final doc = await _pessoas.doc(id).get();
      final dados = doc.data();
      if (!doc.exists || dados == null) return Error(PersonNotFoundFailure());
      return Success(PessoaMapper.fromFirestore(doc.id, dados));
    } catch (e) {
      return Error(FirestoreFailure('Erro ao buscar pessoa: $e'));
    }
  }

  @override
  Future<PessoaResult> buscarPorUsuarioUid(String usuarioUid) async {
    try {
      final snapshot = await _pessoas
          .where('usuarioUid', isEqualTo: usuarioUid)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return Error(PersonNotFoundFailure());

      final doc = snapshot.docs.first;
      return Success(PessoaMapper.fromFirestore(doc.id, doc.data()));
    } catch (e) {
      return Error(FirestoreFailure('Erro ao buscar pessoa do usuário: $e'));
    }
  }
}
