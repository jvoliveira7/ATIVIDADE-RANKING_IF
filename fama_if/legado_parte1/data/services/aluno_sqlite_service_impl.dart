import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../core/database/app_database.dart';
import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/aluno.dart';
import '../../domain/models/aluno_mapper.dart';
import 'aluno_local_storage_interface.dart';

final class AlunoSqliteService implements IAlunoLocalStorage {
  final AppDatabase _appDatabase;

  AlunoSqliteService({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  //converte um Aluno] para o Map que o SQLite espera
  Map<String, dynamic> _alunoParaLinha(Aluno aluno) {
    return {
      AppDatabase.columnId: aluno.id,
      AppDatabase.columnNome: aluno.nome,
      AppDatabase.columnCurso: aluno.curso.name,
      AppDatabase.columnTurmaAno: aluno.turmaAno,
      AppDatabase.columnApelido: aluno.apelido,
      AppDatabase.columnDataNascimento:
          aluno.dataNascimento.toIso8601String(),
      //os 15 critérios viram JSON numa coluna só.
      AppDatabase.columnCriteriosJson:
          jsonEncode(AlunoMapper.criteriosParaMap(aluno.criterios)),
    };
  }

  ///converte uma linha do SQLite de volta para um objeto 
  Aluno _linhaParaAluno(Map<String, dynamic> linha) {
    return AlunoMapper.fromMap({
      'id': linha[AppDatabase.columnId],
      'nome': linha[AppDatabase.columnNome],
      'curso': linha[AppDatabase.columnCurso],
      'turmaAno': linha[AppDatabase.columnTurmaAno],
      'apelido': linha[AppDatabase.columnApelido],
      'dataNascimento': linha[AppDatabase.columnDataNascimento],
      'criterios': jsonDecode(linha[AppDatabase.columnCriteriosJson] as String),
    });
  }

  @override
  Future<ListAlunoResult> buscarTodosAlunos() async {
    try {
      final db = await _appDatabase.database;
      // SELECT * FROM alunos
      final linhas = await db.query(AppDatabase.tableAlunos);
      final alunos = linhas.map(_linhaParaAluno).toList();
      return Success(alunos);
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao buscar alunos no SQLite: $e'));
    }
  }

  @override
  Future<AlunoResult> buscarAlunoPorId(String id) async {
    try {
      final db = await _appDatabase.database;
      //select * FROM alunos WHERE id = ?
      final linhas = await db.query(
        AppDatabase.tableAlunos,
        where: '${AppDatabase.columnId} = ?',
        whereArgs: [id],
      );
      if (linhas.isEmpty) return Error(StudentNotFoundFailure());
      return Success(_linhaParaAluno(linhas.first));
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao buscar aluno por id: $e'));
    }
  }

  @override
  Future<AlunoResult> salvarAluno(Aluno aluno) async {
    try {
      final db = await _appDatabase.database;
      //INSERT INTO alunos VALUES
      await db.insert(
        AppDatabase.tableAlunos,
        _alunoParaLinha(aluno),
        //se já existir um aluno com o mesmo id, troca
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return Success(aluno);
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao salvar aluno no SQLite: $e'));
    }
  }

  @override
  Future<AlunoResult> atualizarAluno(Aluno aluno) async {
    try {
      final db = await _appDatabase.database;
      // UPDATE alunos SET
      final linhasAfetadas = await db.update(
        AppDatabase.tableAlunos,
        _alunoParaLinha(aluno),
        where: '${AppDatabase.columnId} = ?',
        whereArgs: [aluno.id],
      );
      if (linhasAfetadas == 0) return Error(StudentNotFoundFailure());
      return Success(aluno);
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao atualizar aluno no SQLite: $e'));
    }
  }

  @override
  Future<BoolResult> removerAluno(String id) async {
    try {
      final db = await _appDatabase.database;
      // DELETE FROM alunos WHERE id = ?
      final linhasAfetadas = await db.delete(
        AppDatabase.tableAlunos,
        where: '${AppDatabase.columnId} = ?',
        whereArgs: [id],
      );
      if (linhasAfetadas == 0) return Error(StudentNotFoundFailure());
      return const Success(true);
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao remover aluno do SQLite: $e'));
    }
  }
}
