import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/avaliacao.dart';
import '../../domain/models/avaliacao_mapper.dart';
import 'i_avaliacao_service.dart';

/// Acesso à coleção `avaliacoes` do Firestore (itens 3.2, 15 e 16).
final class FirestoreAvaliacaoService implements IAvaliacaoService {
  static const String colecao = 'avaliacoes';

  final FirebaseFirestore _firestore;

  FirestoreAvaliacaoService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _avaliacoes =>
      _firestore.collection(colecao);

  @override
  Future<AvaliacaoResult> salvar(Avaliacao avaliacao) async {
    try {
      await _avaliacoes
          .doc(avaliacao.id)
          .set(AvaliacaoMapper.toFirestore(avaliacao));
      return Success(avaliacao);
    } catch (e) {
      return Error(FirestoreFailure('Erro ao salvar avaliação: $e'));
    }
  }

  @override
  Future<AvaliacaoResult> buscarPorAvaliadorEPessoa({
    required String avaliadorUid,
    required String pessoaId,
  }) async {
    try {
      final id = Avaliacao.idPara(
        avaliadorUid: avaliadorUid,
        pessoaId: pessoaId,
      );
      final doc = await _avaliacoes.doc(id).get();
      final dados = doc.data();
      if (!doc.exists || dados == null) {
        return Error(EvaluationNotFoundFailure());
      }
      return Success(AvaliacaoMapper.fromFirestore(doc.id, dados));
    } catch (e) {
      return Error(FirestoreFailure('Erro ao buscar avaliação: $e'));
    }
  }

  @override
  Future<ListAvaliacaoResult> buscarPorAvaliador(String avaliadorUid) async {
    try {
      final snapshot = await _avaliacoes
          .where('avaliadorUid', isEqualTo: avaliadorUid)
          .get();
      return Success(_mapear(snapshot));
    } catch (e) {
      return Error(FirestoreFailure('Erro ao buscar suas avaliações: $e'));
    }
  }

  @override
  Future<ListAvaliacaoResult> buscarTodas() async {
    try {
      final snapshot = await _avaliacoes.get();
      return Success(_mapear(snapshot));
    } catch (e) {
      return Error(FirestoreFailure('Erro ao buscar avaliações: $e'));
    }
  }

  @override
  Future<VoidResult> remover(String id) async {
    try {
      await _avaliacoes.doc(id).delete();
      return const Success(null);
    } catch (e) {
      return Error(FirestoreFailure('Erro ao remover avaliação: $e'));
    }
  }

  List<Avaliacao> _mapear(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs
        .map((doc) => AvaliacaoMapper.fromFirestore(doc.id, doc.data()))
        .toList();
  }
}
