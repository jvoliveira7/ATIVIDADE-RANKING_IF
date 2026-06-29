import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/aluno.dart';
import '../../domain/models/aluno_mapper.dart';
import 'aluno_local_storage_interface.dart';

/// Implementação concreta do armazenamento local de alunos usando
/// SharedPreferences.
///
/// Estratégia (igual à usada pelo professor em `CharacterSharedPreferencesService`):
/// como o SharedPreferences só guarda tipos simples (String, int, bool...),
/// a lista inteira de alunos é convertida para uma única String JSON e
/// salva sob uma chave fixa (`_storageKey`). Para qualquer operação de
/// escrita (salvar, atualizar, remover), o fluxo é sempre:
///   1) ler a lista completa atual do SharedPreferences
///   2) modificar essa lista em memória (adicionar/editar/remover o item)
///   3) regravar a lista inteira de volta como JSON
final class AlunoSharedPreferencesService implements IAlunoLocalStorage {
  static const String _storageKey = 'alunos';

  @override
  Future<ListAlunoResult> buscarTodosAlunos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString == null || jsonString.isEmpty) {
        // Lista vazia não é um erro: é o estado normal de um app novo.
        return const Success([]);
      }

      final decoded = jsonDecode(jsonString) as List<dynamic>;
      final alunos = decoded
          .map((item) => AlunoMapper.fromMap(item as Map<String, dynamic>))
          .toList();

      return Success(alunos);
    } catch (e) {
      return Error(
        ApiLocalFailure('Erro ao buscar alunos no armazenamento local: $e'),
      );
    }
  }

  @override
  Future<AlunoResult> buscarAlunoPorId(String id) async {
    final resultadoLista = await buscarTodosAlunos();

    return resultadoLista.fold(
      onSuccess: (alunos) {
        final encontrado = alunos.where((a) => a.id == id).firstOrNull;
        if (encontrado == null) {
          return Error(StudentNotFoundFailure());
        }
        return Success(encontrado);
      },
      onFailure: (falha) => Error(falha),
    );
  }

  @override
  Future<AlunoResult> salvarAluno(Aluno aluno) async {
    try {
      final resultadoLista = await buscarTodosAlunos();

      return await resultadoLista.fold(
        onSuccess: (alunos) async {
          final novaLista = [...alunos, aluno];
          await _salvarLista(novaLista);
          return Success(aluno);
        },
        onFailure: (falha) async => Error(falha),
      );
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao salvar aluno: $e'));
    }
  }

  @override
  Future<AlunoResult> atualizarAluno(Aluno aluno) async {
    try {
      final resultadoLista = await buscarTodosAlunos();

      return await resultadoLista.fold(
        onSuccess: (alunos) async {
          final indice = alunos.indexWhere((a) => a.id == aluno.id);
          if (indice == -1) {
            return Error(StudentNotFoundFailure());
          }

          final novaLista = [...alunos];
          novaLista[indice] = aluno;
          await _salvarLista(novaLista);
          return Success(aluno);
        },
        onFailure: (falha) async => Error(falha),
      );
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao atualizar aluno: $e'));
    }
  }

  @override
  Future<BoolResult> removerAluno(String id) async {
    try {
      final resultadoLista = await buscarTodosAlunos();

      return await resultadoLista.fold(
        onSuccess: (alunos) async {
          final existiaAntes = alunos.any((a) => a.id == id);
          if (!existiaAntes) {
            return Error(StudentNotFoundFailure());
          }

          final novaLista = alunos.where((a) => a.id != id).toList();
          await _salvarLista(novaLista);
          return const Success(true);
        },
        onFailure: (falha) async => Error(falha),
      );
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao remover aluno: $e'));
    }
  }

  /// Serializa a lista completa de alunos para JSON e grava no
  /// SharedPreferences, sobrescrevendo o valor anterior.
  Future<void> _salvarLista(List<Aluno> alunos) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(
      alunos.map((a) => AlunoMapper.toMap(a)).toList(),
    );
    await prefs.setString(_storageKey, jsonString);
  }
}
