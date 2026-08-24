import '../messages/app_messages.dart';

/// Classe selada que representa as falhas possíveis no domínio do app.
/// Cada subtipo representa uma categoria de erro específica,
/// permitindo tratamento diferenciado em cada camada (UI, ViewModel, etc).
sealed class Failure implements Exception {
  final String msg;
  Failure(this.msg);

  @override
  String toString() => '$runtimeType: $msg';
}

/// Erro genérico, usado quando nenhuma outra falha específica se aplica.
class DefaultFailure extends Failure {
  DefaultFailure([String? msg]) : super(msg ?? AppMessages.error.defaultError);
}

/// Erro ao acessar o armazenamento local / banco SQLite (leitura, escrita ou remoção).
class ApiLocalFailure extends Failure {
  ApiLocalFailure([String? msg]) : super(msg ?? AppMessages.error.apiLocalError);
}

/// Indica que uma busca não encontrou nenhum resultado.
class EmptyResultFailure extends Failure {
  EmptyResultFailure([String? msg])
      : super(msg ?? AppMessages.error.emptyResultError);
}

/// Erro de entrada inválida (parâmetro nulo, formato incorreto, etc).
class InputFailure extends Failure {
  InputFailure([String? msg]) : super(msg ?? AppMessages.error.inputError);
}

/// Data de nascimento inválida ou não selecionada.
class InvalidDateFailure extends Failure {
  InvalidDateFailure([String? msg])
      : super(msg ?? AppMessages.error.invalidDateError);
}

/// Curso selecionado não está entre as opções pré-definidas.
class InvalidCourseFailure extends Failure {
  InvalidCourseFailure([String? msg])
      : super(msg ?? AppMessages.error.invalidCourseError);
}

/// Turma/ano fora do intervalo permitido (1998-2026).
class InvalidYearFailure extends Failure {
  InvalidYearFailure([String? msg])
      : super(msg ?? AppMessages.error.invalidYearError);
}

/// Nota de algum critério fora do intervalo permitido (1-5 estrelas).
class InvalidStarRatingFailure extends Failure {
  InvalidStarRatingFailure([String? msg])
      : super(msg ?? AppMessages.error.invalidStarRatingError);
}

/// Aluno não encontrado pelo identificador informado.
class StudentNotFoundFailure extends Failure {
  StudentNotFoundFailure([String? msg])
      : super(msg ?? AppMessages.error.studentNotFoundError);
}
