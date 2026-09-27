/// Mensagens de erro centralizadas do aplicativo.
/// Mantém todos os textos de erro em um único lugar,
/// facilitando manutenção e eventual tradução.
class AppMessages {
  static const error = _Error();
}

class _Error {
  const _Error();

  final String defaultError = 'Ocorreu um erro inesperado.';
  final String apiLocalError = 'Erro ao acessar o armazenamento local.';
  final String firestoreError = 'Não foi possível acessar os dados no servidor.';
  final String emptyResultError = 'Nenhum resultado encontrado.';
  final String inputError = 'Entrada inválida.';

  final String nullStringError = 'Este campo não pode ficar vazio.';
  final String invalidDateError = 'Data inválida. Selecione uma data válida.';
  final String invalidCourseError = 'Selecione um curso válido.';
  final String invalidYearError = 'Selecione uma turma/ano entre 1998 e 2026.';
  final String invalidStarRatingError = 'A nota deve estar entre 1 e 5 estrelas.';
  final String personNotFoundError = 'Pessoa não encontrada.';
  final String evaluationNotFoundError = 'Você ainda não avaliou esta pessoa.';

  // Autenticação e sessão
  final String unauthenticatedError =
      'É preciso estar autenticado para continuar.';
  final String sessionExpiredError =
      'Sua sessão expirou. Entre novamente para continuar.';
  final String invalidCredentialsError = 'E-mail ou senha incorretos.';
  final String emailAlreadyInUseError = 'Este e-mail já está cadastrado.';
  final String weakPasswordError =
      'A senha precisa ter pelo menos 6 caracteres.';
  final String authCancelledError = 'Login cancelado.';
  final String authError = 'Não foi possível concluir a autenticação.';

  // Regras de avaliação
  final String selfEvaluationError = 'Você não pode avaliar a si próprio.';
}
