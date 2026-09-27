import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
 
  AppDatabase._internal();

  static final AppDatabase instance = AppDatabase._internal();

  static Database? _database;

  static const String _databaseName = 'fama_if.db';

  static const int _databaseVersion = 1;

  //nome da tabela e das colunas
  static const String tableAlunos = 'alunos';
  static const String columnId = 'id';
  static const String columnNome = 'nome';
  static const String columnCurso = 'curso';
  static const String columnTurmaAno = 'turma_ano';
  static const String columnApelido = 'apelido';
  static const String columnDataNascimento = 'data_nascimento';
  static const String columnCriteriosJson = 'criterios_json';

  /// Retorna o banco de dados, criando-o se ainda não existir.
  /// O `??=` garante que o banco só é criado uma vez.
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Inicializa o banco: define o caminho do arquivo e abre a conexão.
  Future<Database> _initDatabase() async {
    // getDatabasesPath() retorna o diretório padrão do SQLite no dispositivo.
    final databasesPath = await getDatabasesPath();

    // join() monta o caminho completo: ex "/data/user/0/.../fama_if.db"
    final path = join(databasesPath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Chamado automaticamente na PRIMEIRA vez que o banco é criado.
  /// Define a estrutura da tabela de alunos.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableAlunos (
        $columnId           TEXT PRIMARY KEY,
        $columnNome         TEXT NOT NULL,
        $columnCurso        TEXT NOT NULL,
        $columnTurmaAno     INTEGER NOT NULL,
        $columnApelido      TEXT NOT NULL,
        $columnDataNascimento TEXT NOT NULL,
        $columnCriteriosJson  TEXT NOT NULL
      )
    ''');
  }

  /// Chamado automaticamente quando a versão do banco aumenta.
  /// Por enquanto não há migrações, mas a estrutura já está pronta
  /// caso o app evolua no futuro (ex: adicionar uma coluna nova).
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Exemplo de migração futura:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE $tableAlunos ADD COLUMN foto TEXT');
    // }
  }

  /// Fecha a conexão com o banco. Chamado quando o app é encerrado.
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
