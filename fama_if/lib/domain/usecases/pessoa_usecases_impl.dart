import 'package:uuid/uuid.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../data/repositories/i_auth_repository.dart';
import '../../data/repositories/i_pessoa_repository.dart';
import 'i_pessoa_usecases.dart';

/// Cadastra uma pessoa para ser avaliada (item 14.5).
///
/// Gera o id e carimba `criadoPor` com o usuário autenticado. Cadastrar uma
/// pessoa não cria conta de autenticação nenhuma (item 7).
final class CadastrarPessoaUseCase implements ICadastrarPessoaUseCase {
  final IPessoaRepository _repository;
  final IAuthRepository _authRepository;
  final Uuid _uuid;

  CadastrarPessoaUseCase({
    required IPessoaRepository repository,
    required IAuthRepository authRepository,
    Uuid? uuid,
  })  : _repository = repository,
        _authRepository = authRepository,
        _uuid = uuid ?? const Uuid();

  @override
  Future<PessoaResult> call(PessoaParams params) async {
    final usuario = _authRepository.usuarioAtual;
    if (usuario == null) return Error(UnauthenticatedFailure());

    final pessoa = params.pessoa.copyWith(
      id: _uuid.v4(),
      criadoPor: usuario.uid,
    );
    return _repository.cadastrar(pessoa);
  }
}

/// Altera os dados cadastrais de uma pessoa (item 14.8).
///
/// Só quem cadastrou pode alterar — a mesma regra vale nas Security Rules,
/// para que a restrição não dependa apenas do aplicativo.
final class AlterarPessoaUseCase implements IAlterarPessoaUseCase {
  final IPessoaRepository _repository;
  final IAuthRepository _authRepository;

  AlterarPessoaUseCase({
    required IPessoaRepository repository,
    required IAuthRepository authRepository,
  })  : _repository = repository,
        _authRepository = authRepository;

  @override
  Future<PessoaResult> call(PessoaParams params) async {
    final usuario = _authRepository.usuarioAtual;
    if (usuario == null) return Error(UnauthenticatedFailure());

    final atual = await _repository.buscarPorId(params.pessoa.id);

    return atual.fold(
      onSuccess: (pessoa) async {
        if (pessoa.criadoPor != usuario.uid) {
          return Error(
            InputFailure('Só quem cadastrou esta pessoa pode alterá-la.'),
          );
        }
        // Preserva os campos que a tela de edição não controla.
        return _repository.alterar(
          params.pessoa.copyWith(
            criadoPor: pessoa.criadoPor,
            usuarioUid: pessoa.usuarioUid,
          ),
        );
      },
      onFailure: (falha) async => Error(falha),
    );
  }
}

/// Remove uma pessoa (item 14.9). A confirmação é responsabilidade da UI.
///
/// As avaliações que ela recebeu não são apagadas em cascata: os rankings
/// cruzam avaliações com pessoas existentes, então registros órfãos
/// simplesmente deixam de aparecer.
final class RemoverPessoaUseCase implements IRemoverPessoaUseCase {
  final IPessoaRepository _repository;
  final IAuthRepository _authRepository;

  RemoverPessoaUseCase({
    required IPessoaRepository repository,
    required IAuthRepository authRepository,
  })  : _repository = repository,
        _authRepository = authRepository;

  @override
  Future<VoidResult> call(IdParams params) async {
    final usuario = _authRepository.usuarioAtual;
    if (usuario == null) return Error(UnauthenticatedFailure());

    final atual = await _repository.buscarPorId(params.id);

    return atual.fold(
      onSuccess: (pessoa) async {
        if (pessoa.criadoPor != usuario.uid) {
          return Error(
            InputFailure('Só quem cadastrou esta pessoa pode removê-la.'),
          );
        }
        return _repository.remover(params.id);
      },
      onFailure: (falha) async => Error(falha),
    );
  }
}

/// Lista as pessoas cadastradas (item 14.6). A lista é comum a todos os
/// usuários autenticados, já que o ranking global depende de várias pessoas
/// avaliarem as mesmas pessoas.
final class BuscarTodasPessoasUseCase implements IBuscarTodasPessoasUseCase {
  final IPessoaRepository _repository;

  BuscarTodasPessoasUseCase({required IPessoaRepository repository})
      : _repository = repository;

  @override
  Future<ListPessoaResult> call(NoParams params) => _repository.buscarTodas();
}

/// Busca uma pessoa pelo identificador (item 14.7).
final class BuscarPessoaPorIdUseCase implements IBuscarPessoaPorIdUseCase {
  final IPessoaRepository _repository;

  BuscarPessoaPorIdUseCase({required IPessoaRepository repository})
      : _repository = repository;

  @override
  Future<PessoaResult> call(IdParams params) =>
      _repository.buscarPorId(params.id);
}
