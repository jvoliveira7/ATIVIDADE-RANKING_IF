import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../data/repositories/i_auth_repository.dart';
import '../../data/repositories/i_avaliacao_repository.dart';
import '../../data/repositories/i_pessoa_repository.dart';
import '../models/avaliacao.dart';
import 'i_avaliacao_usecases.dart';

/// Regras comuns a registrar e alterar uma avaliação (item 16): exige sessão,
/// exige que a pessoa exista, barra autoavaliação e valida as notas.
mixin _ValidacaoAvaliacao {
  IAuthRepository get authRepository;
  IPessoaRepository get pessoaRepository;

  Future<AvaliacaoResult> montarAvaliacao(AvaliarParams params) async {
    final usuario = authRepository.usuarioAtual;
    if (usuario == null) return Error(UnauthenticatedFailure());

    final pessoaResult = await pessoaRepository.buscarPorId(params.pessoaId);

    return pessoaResult.fold(
      onSuccess: (pessoa) {
        if (pessoa.ehOProprioUsuario(usuario.uid)) {
          return Error<Avaliacao, Failure>(SelfEvaluationFailure());
        }
        try {
          // O construtor da entidade valida as 15 notas (1 a 5 estrelas).
          return Success<Avaliacao, Failure>(
            Avaliacao.nova(
              avaliadorUid: usuario.uid,
              pessoaId: pessoa.id,
              criterios: params.criterios,
            ),
          );
        } on Failure catch (falha) {
          return Error<Avaliacao, Failure>(falha);
        }
      },
      onFailure: (falha) => Error<Avaliacao, Failure>(falha),
    );
  }
}

/// Registra a avaliação do usuário autenticado sobre uma pessoa (item 14.10).
final class RegistrarAvaliacaoUseCase
    with _ValidacaoAvaliacao
    implements IRegistrarAvaliacaoUseCase {
  @override
  final IAuthRepository authRepository;
  @override
  final IPessoaRepository pessoaRepository;

  final IAvaliacaoRepository _avaliacaoRepository;

  RegistrarAvaliacaoUseCase({
    required this.authRepository,
    required this.pessoaRepository,
    required IAvaliacaoRepository avaliacaoRepository,
  }) : _avaliacaoRepository = avaliacaoRepository;

  @override
  Future<AvaliacaoResult> call(AvaliarParams params) async {
    final montada = await montarAvaliacao(params);

    return montada.fold(
      onSuccess: (avaliacao) async => _avaliacaoRepository.salvar(avaliacao),
      onFailure: (falha) async => Error(falha),
    );
  }
}

/// Altera uma avaliação já existente (item 14.11).
///
/// Diferente de registrar, aqui a avaliação precisa existir: é o que impede
/// que "alterar" crie um registro novo por engano e fure a regra de uma
/// avaliação ativa por par usuário + pessoa (item 16).
final class AlterarAvaliacaoUseCase
    with _ValidacaoAvaliacao
    implements IAlterarAvaliacaoUseCase {
  @override
  final IAuthRepository authRepository;
  @override
  final IPessoaRepository pessoaRepository;

  final IAvaliacaoRepository _avaliacaoRepository;

  AlterarAvaliacaoUseCase({
    required this.authRepository,
    required this.pessoaRepository,
    required IAvaliacaoRepository avaliacaoRepository,
  }) : _avaliacaoRepository = avaliacaoRepository;

  @override
  Future<AvaliacaoResult> call(AvaliarParams params) async {
    final usuario = authRepository.usuarioAtual;
    if (usuario == null) return Error(UnauthenticatedFailure());

    final existente = await _avaliacaoRepository.buscarPorAvaliadorEPessoa(
      avaliadorUid: usuario.uid,
      pessoaId: params.pessoaId,
    );
    if (existente.isFailure) return existente;

    final montada = await montarAvaliacao(params);

    return montada.fold(
      onSuccess: (avaliacao) async => _avaliacaoRepository.salvar(avaliacao),
      onFailure: (falha) async => Error(falha),
    );
  }
}

/// Consulta a avaliação que o usuário autenticado deu para uma pessoa.
final class ConsultarAvaliacaoUseCase implements IConsultarAvaliacaoUseCase {
  final IAuthRepository _authRepository;
  final IAvaliacaoRepository _avaliacaoRepository;

  ConsultarAvaliacaoUseCase({
    required IAuthRepository authRepository,
    required IAvaliacaoRepository avaliacaoRepository,
  })  : _authRepository = authRepository,
        _avaliacaoRepository = avaliacaoRepository;

  @override
  Future<AvaliacaoResult> call(IdParams params) async {
    final usuario = _authRepository.usuarioAtual;
    if (usuario == null) return Error(UnauthenticatedFailure());

    return _avaliacaoRepository.buscarPorAvaliadorEPessoa(
      avaliadorUid: usuario.uid,
      pessoaId: params.id,
    );
  }
}

/// Todas as avaliações feitas pelo usuário autenticado (item 4.3).
final class BuscarAvaliacoesDoUsuarioUseCase
    implements IBuscarAvaliacoesDoUsuarioUseCase {
  final IAuthRepository _authRepository;
  final IAvaliacaoRepository _avaliacaoRepository;

  BuscarAvaliacoesDoUsuarioUseCase({
    required IAuthRepository authRepository,
    required IAvaliacaoRepository avaliacaoRepository,
  })  : _authRepository = authRepository,
        _avaliacaoRepository = avaliacaoRepository;

  @override
  Future<ListAvaliacaoResult> call(NoParams params) async {
    final usuario = _authRepository.usuarioAtual;
    if (usuario == null) return Error(UnauthenticatedFailure());

    return _avaliacaoRepository.buscarPorAvaliador(usuario.uid);
  }
}

/// Diz se a pessoa informada é o próprio usuário autenticado (item 14.12).
/// A UI usa isso para esconder o botão de avaliar antes mesmo da tentativa.
final class VerificarAutoavaliacaoUseCase
    implements IVerificarAutoavaliacaoUseCase {
  final IAuthRepository _authRepository;
  final IPessoaRepository _pessoaRepository;

  VerificarAutoavaliacaoUseCase({
    required IAuthRepository authRepository,
    required IPessoaRepository pessoaRepository,
  })  : _authRepository = authRepository,
        _pessoaRepository = pessoaRepository;

  @override
  Future<BoolResult> call(IdParams params) async {
    final usuario = _authRepository.usuarioAtual;
    if (usuario == null) return Error(UnauthenticatedFailure());

    final pessoaResult = await _pessoaRepository.buscarPorId(params.id);

    return pessoaResult.fold(
      onSuccess: (pessoa) => Success(pessoa.ehOProprioUsuario(usuario.uid)),
      onFailure: (falha) => Error(falha),
    );
  }
}
