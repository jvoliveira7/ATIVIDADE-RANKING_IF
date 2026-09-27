import 'package:fama_if/core/typedefs/types_defs.dart';
import 'package:fama_if/data/repositories/i_auth_repository.dart';
import 'package:fama_if/domain/models/criterios_popularidade.dart';
import 'package:fama_if/domain/models/curso.dart';
import 'package:fama_if/domain/models/pessoa.dart';
import 'package:fama_if/domain/models/usuario.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Repositório de autenticação de mentira, para os testes controlarem quem
/// está logado sem subir Firebase nenhum.
class FakeAuthRepository implements IAuthRepository {
  final Signal<Usuario?> _usuario = signal<Usuario?>(null);

  void entrarComo(Usuario? usuario) => _usuario.value = usuario;

  @override
  Signal<Usuario?> get usuarioAtualSignal => _usuario;

  @override
  Usuario? get usuarioAtual => _usuario.value;

  @override
  Future<void> inicializarSessao() async {}

  @override
  Future<UsuarioResult> entrarComEmail(String email, String senha) =>
      throw UnimplementedError();

  @override
  Future<UsuarioResult> cadastrarComEmail({
    required String nome,
    required String email,
    required String senha,
  }) =>
      throw UnimplementedError();

  @override
  Future<UsuarioResult> entrarComGoogle() => throw UnimplementedError();

  @override
  Future<VoidResult> sair() => throw UnimplementedError();
}

Usuario usuarioFake({
  String uid = 'uid-1',
  String nome = 'Usuário Teste',
  String? pessoaId,
}) {
  return Usuario(
    uid: uid,
    nome: nome,
    email: '$uid@ifpr.edu.br',
    provider: AuthProvider.emailSenha,
    pessoaId: pessoaId,
  );
}

Pessoa pessoaFake({
  required String id,
  String nome = 'Pessoa Teste',
  String criadoPor = 'uid-1',
  String? usuarioUid,
}) {
  return Pessoa(
    id: id,
    nome: nome,
    apelido: 'Apelido',
    curso: Curso.tads,
    turmaAno: 2026,
    dataNascimento: DateTime(2004, 5, 20),
    criadoPor: criadoPor,
    usuarioUid: usuarioUid,
  );
}

/// Monta os 15 critérios somando exatamente [total] pontos, distribuindo o
/// excedente campo a campo. Útil para reproduzir os exemplos numéricos da
/// especificação sem escrever 15 notas à mão.
CriteriosPopularidade criteriosComTotal(int total) {
  var criterios = CriteriosPopularidade.inicial();
  var restante = total - 15;

  for (final item in criterios.items) {
    final acrescimo = restante.clamp(0, 4);
    criterios = item.setValue(criterios, 1 + acrescimo);
    restante -= acrescimo;
  }

  return criterios;
}
