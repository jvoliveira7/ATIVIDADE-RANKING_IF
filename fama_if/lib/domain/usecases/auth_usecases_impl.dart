import 'package:uuid/uuid.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../data/repositories/i_auth_repository.dart';
import '../../data/repositories/i_pessoa_repository.dart';
import '../../data/repositories/i_usuario_repository.dart';
import '../models/pessoa.dart';
import '../models/usuario.dart';
import 'i_auth_usecases.dart';

/// Cadastra um usuário no Firebase Authentication e cria o perfil dele na
/// coleção `usuarios` do Firestore (itens 14.1 e 15).
final class CadastrarUsuarioUseCase implements ICadastrarUsuarioUseCase {
  final IAuthRepository _authRepository;
  final IUsuarioRepository _usuarioRepository;

  CadastrarUsuarioUseCase({
    required IAuthRepository authRepository,
    required IUsuarioRepository usuarioRepository,
  })  : _authRepository = authRepository,
        _usuarioRepository = usuarioRepository;

  @override
  Future<UsuarioResult> call(SignUpParams params) async {
    if (params.nome.trim().isEmpty) {
      return Error(InputFailure('Informe seu nome.'));
    }
    if (params.senha.length < 6) {
      return Error(WeakPasswordFailure());
    }

    final resultado = await _authRepository.cadastrarComEmail(
      nome: params.nome,
      email: params.email,
      senha: params.senha,
    );

    return resultado.fold(
      onSuccess: (usuario) async => _usuarioRepository.salvar(usuario),
      onFailure: (falha) async => Error(falha),
    );
  }
}

/// Login com e-mail e senha (item 14.2).
final class EntrarComEmailUseCase implements IEntrarComEmailUseCase {
  final IAuthRepository _authRepository;
  final IUsuarioRepository _usuarioRepository;

  EntrarComEmailUseCase({
    required IAuthRepository authRepository,
    required IUsuarioRepository usuarioRepository,
  })  : _authRepository = authRepository,
        _usuarioRepository = usuarioRepository;

  @override
  Future<UsuarioResult> call(SignInParams params) async {
    if (params.email.trim().isEmpty || params.senha.isEmpty) {
      return Error(InputFailure('Informe e-mail e senha.'));
    }

    final resultado = await _authRepository.entrarComEmail(
      params.email,
      params.senha,
    );

    return resultado.fold(
      onSuccess: (usuario) async => _carregarPerfil(usuario),
      onFailure: (falha) async => Error(falha),
    );
  }

  /// O perfil no Firestore é a fonte do `pessoaId`; o Firebase Auth sozinho
  /// não conhece esse vínculo.
  Future<UsuarioResult> _carregarPerfil(Usuario usuario) async {
    final perfil = await _usuarioRepository.buscarPorUid(usuario.uid);
    return perfil.fold(
      onSuccess: (salvo) => Success(salvo),
      // Conta criada antes de existir o perfil no Firestore: cria agora.
      onFailure: (_) => Success(usuario),
    );
  }
}

/// Login com conta Google (itens 3.1 e 14.2).
final class EntrarComGoogleUseCase implements IEntrarComGoogleUseCase {
  final IAuthRepository _authRepository;
  final IUsuarioRepository _usuarioRepository;

  EntrarComGoogleUseCase({
    required IAuthRepository authRepository,
    required IUsuarioRepository usuarioRepository,
  })  : _authRepository = authRepository,
        _usuarioRepository = usuarioRepository;

  @override
  Future<UsuarioResult> call(NoParams params) async {
    final resultado = await _authRepository.entrarComGoogle();

    return resultado.fold(
      onSuccess: (usuario) async {
        // Primeiro login com Google ainda não tem perfil no Firestore.
        final perfil = await _usuarioRepository.buscarPorUid(usuario.uid);
        return perfil.fold(
          onSuccess: (salvo) async => Success(salvo),
          onFailure: (_) async => _usuarioRepository.salvar(usuario),
        );
      },
      onFailure: (falha) async => Error(falha),
    );
  }
}

/// Verifica se há usuário autenticado (item 4.3), usado pela splash e pelas
/// travas de navegação.
final class VerificarUsuarioAutenticadoUseCase
    implements IVerificarUsuarioAutenticadoUseCase {
  final IAuthRepository _authRepository;
  final IUsuarioRepository _usuarioRepository;

  VerificarUsuarioAutenticadoUseCase({
    required IAuthRepository authRepository,
    required IUsuarioRepository usuarioRepository,
  })  : _authRepository = authRepository,
        _usuarioRepository = usuarioRepository;

  @override
  Future<UsuarioResult> call(NoParams params) async {
    await _authRepository.inicializarSessao();

    final usuario = _authRepository.usuarioAtual;
    if (usuario == null) return Error(UnauthenticatedFailure());

    final perfil = await _usuarioRepository.buscarPorUid(usuario.uid);
    return perfil.fold(
      onSuccess: (salvo) => Success(salvo),
      onFailure: (_) => Success(usuario),
    );
  }
}

/// Encerra a sessão (item 14.4).
final class SairUseCase implements ISairUseCase {
  final IAuthRepository _authRepository;

  SairUseCase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<VoidResult> call(NoParams params) => _authRepository.sair();
}

/// Cria a pessoa que representa o usuário logado e grava o vínculo nos dois
/// lados: `pessoas.usuarioUid` e `usuarios.pessoaId` (itens 5 e 14.12).
final class CompletarPerfilUseCase implements ICompletarPerfilUseCase {
  final IAuthRepository _authRepository;
  final IUsuarioRepository _usuarioRepository;
  final IPessoaRepository _pessoaRepository;
  final Uuid _uuid;

  CompletarPerfilUseCase({
    required IAuthRepository authRepository,
    required IUsuarioRepository usuarioRepository,
    required IPessoaRepository pessoaRepository,
    Uuid? uuid,
  })  : _authRepository = authRepository,
        _usuarioRepository = usuarioRepository,
        _pessoaRepository = pessoaRepository,
        _uuid = uuid ?? const Uuid();

  @override
  Future<PessoaResult> call(CompletarPerfilParams params) async {
    final usuario = _authRepository.usuarioAtual;
    if (usuario == null) return Error(UnauthenticatedFailure());

    // Se já existe pessoa vinculada, não cria outra: o vínculo é um para um.
    final existente = await _pessoaRepository.buscarPorUsuarioUid(usuario.uid);
    if (existente.isSuccess) return existente;

    final pessoa = Pessoa(
      id: _uuid.v4(),
      nome: usuario.nome,
      apelido: params.apelido,
      curso: params.curso,
      turmaAno: params.turmaAno,
      dataNascimento: params.dataNascimento,
      criadoPor: usuario.uid,
      usuarioUid: usuario.uid,
    );

    final cadastrada = await _pessoaRepository.cadastrar(pessoa);

    return cadastrada.fold(
      onSuccess: (nova) async {
        final vinculo = await _usuarioRepository.vincularPessoa(
          uid: usuario.uid,
          pessoaId: nova.id,
        );
        return vinculo.fold(
          onSuccess: (_) => Success(nova),
          onFailure: (falha) => Error(falha),
        );
      },
      onFailure: (falha) async => Error(falha),
    );
  }
}
