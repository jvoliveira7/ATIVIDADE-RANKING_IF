import '../../core/typedefs/types_defs.dart';
import '../../domain/models/pessoa.dart';

/// Contrato do serviço de pessoas (item 4.1).
///
/// As pessoas são compartilhadas entre todos os usuários: qualquer um
/// autenticado enxerga a lista inteira, porque o ranking global depende de
/// várias pessoas avaliarem as mesmas pessoas (item 13). O campo `criadoPor`
/// registra quem cadastrou, mas não restringe a leitura.
abstract interface class IPessoaService {
  Future<PessoaResult> salvar(Pessoa pessoa);
  Future<PessoaResult> atualizar(Pessoa pessoa);
  Future<VoidResult> remover(String id);
  Future<ListPessoaResult> buscarTodas();
  Future<PessoaResult> buscarPorId(String id);

  /// Pessoa vinculada a uma conta de usuário, quando existir. É o que permite
  /// descobrir "qual pessoa sou eu" para bloquear a autoavaliação (item 16).
  Future<PessoaResult> buscarPorUsuarioUid(String usuarioUid);
}
