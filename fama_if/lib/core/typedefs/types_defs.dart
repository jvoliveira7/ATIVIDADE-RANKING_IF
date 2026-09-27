import '../../domain/models/avaliacao.dart';
import '../../domain/models/criterios_popularidade.dart';
import '../../domain/models/curso.dart';
import '../../domain/models/item_ranking.dart';
import '../../domain/models/pessoa.dart';
import '../../domain/models/usuario.dart';
import '../failure/failure.dart';
import '../patterns/result.dart';

// typedefs para o tipo Result aplicado a cada entidade do domínio
typedef VoidResult = Result<void, Failure>;
typedef BoolResult = Result<bool, Failure>;
typedef UsuarioResult = Result<Usuario, Failure>;
typedef PessoaResult = Result<Pessoa, Failure>;
typedef ListPessoaResult = Result<List<Pessoa>, Failure>;
typedef AvaliacaoResult = Result<Avaliacao, Failure>;
typedef ListAvaliacaoResult = Result<List<Avaliacao>, Failure>;
typedef RankingResult = Result<List<ItemRanking>, Failure>;

// typedefs para parâmetros usados pelos use cases
typedef NoParams = ();
typedef IdParams = ({String id});
typedef PessoaParams = ({Pessoa pessoa});
typedef AvaliacaoParams = ({Avaliacao avaliacao});

/// Login com e-mail e senha (item 3.1).
typedef SignInParams = ({String email, String senha});

/// Cadastro de usuário (item 14.1). O item 3.1 exige apenas e-mail e senha;
/// o nome entra junto porque o Firebase permite gravá-lo no mesmo passo.
typedef SignUpParams = ({String nome, String email, String senha});

/// Criação da pessoa vinculada à conta, feita logo após o cadastro ou o
/// primeiro login com Google. É esse vínculo que sustenta o bloqueio de
/// autoavaliação (itens 5 e 14.12), e é por isso que ele vale para as duas
/// formas de autenticação, não só para o cadastro por e-mail.
typedef CompletarPerfilParams = ({
  String apelido,
  Curso curso,
  int turmaAno,
  DateTime dataNascimento,
});

/// Registro ou alteração de uma avaliação (itens 14.10 e 14.11).
typedef AvaliarParams = ({String pessoaId, CriteriosPopularidade criterios});

/// Alternância de tema claro/escuro (item 14.15).
typedef TemaParams = ({bool escuro});
