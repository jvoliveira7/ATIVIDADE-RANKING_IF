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

/// Erro ao acessar o armazenamento local (preferências, cache de sessão).
class ApiLocalFailure extends Failure {
  ApiLocalFailure([String? msg]) : super(msg ?? AppMessages.error.apiLocalError);
}

/// Erro de comunicação com o Firestore (leitura, escrita ou remoção).
class FirestoreFailure extends Failure {
  FirestoreFailure([String? msg]) : super(msg ?? AppMessages.error.firestoreError);
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

/// Pessoa não encontrada pelo identificador informado.
class PersonNotFoundFailure extends Failure {
  PersonNotFoundFailure([String? msg])
      : super(msg ?? AppMessages.error.personNotFoundError);
}

/// Avaliação não encontrada para o par usuário + pessoa informado.
class EvaluationNotFoundFailure extends Failure {
  EvaluationNotFoundFailure([String? msg])
      : super(msg ?? AppMessages.error.evaluationNotFoundError);
}

// ---------------------------------------------------------------------------
// Falhas de autenticação e sessão (itens 3.1 e 23 da especificação)
// ---------------------------------------------------------------------------

/// Nenhum usuário autenticado para a operação solicitada.
class UnauthenticatedFailure extends Failure {
  UnauthenticatedFailure([String? msg])
      : super(msg ?? AppMessages.error.unauthenticatedError);
}

/// Sessão existente, porém expirada.
class SessionExpiredFailure extends Failure {
  SessionExpiredFailure([String? msg])
      : super(msg ?? AppMessages.error.sessionExpiredError);
}

/// E-mail ou senha incorretos no login.
class InvalidCredentialsFailure extends Failure {
  InvalidCredentialsFailure([String? msg])
      : super(msg ?? AppMessages.error.invalidCredentialsError);
}

/// Tentativa de cadastro com e-mail já registrado.
class EmailAlreadyInUseFailure extends Failure {
  EmailAlreadyInUseFailure([String? msg])
      : super(msg ?? AppMessages.error.emailAlreadyInUseError);
}

/// Senha que não atende ao mínimo exigido pelo Firebase Authentication.
class WeakPasswordFailure extends Failure {
  WeakPasswordFailure([String? msg])
      : super(msg ?? AppMessages.error.weakPasswordError);
}

/// Usuário interrompeu o fluxo de login (fechou a janela do Google, por exemplo).
class AuthCancelledFailure extends Failure {
  AuthCancelledFailure([String? msg])
      : super(msg ?? AppMessages.error.authCancelledError);
}

/// Falha genérica vinda do Firebase Authentication.
class AuthFailure extends Failure {
  AuthFailure([String? msg]) : super(msg ?? AppMessages.error.authError);
}

/// Tentativa de avaliar a si próprio (itens 9, 14.12 e 16).
class SelfEvaluationFailure extends Failure {
  SelfEvaluationFailure([String? msg])
      : super(msg ?? AppMessages.error.selfEvaluationError);
}
