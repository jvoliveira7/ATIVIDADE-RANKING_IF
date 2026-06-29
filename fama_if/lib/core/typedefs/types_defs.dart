import '../../domain/models/aluno.dart';
import '../failure/failure.dart';
import '../patterns/result.dart';

// typedefs para o tipo Result aplicado ao domínio de Aluno
typedef VoidResult = Result<void, Failure>;
typedef AlunoResult = Result<Aluno, Failure>;
typedef ListAlunoResult = Result<List<Aluno>, Failure>;
typedef BoolResult = Result<bool, Failure>;

// typedefs para parâmetros usados pelos use cases
typedef NoParams = ();
typedef AlunoParams = ({Aluno aluno});
typedef AlunoIdParams = ({String id});
