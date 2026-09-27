import 'usuario.dart';

/// Conversão entre [Usuario] e o documento da coleção `usuarios` (item 15).
class UsuarioMapper {
  const UsuarioMapper._();

  static Map<String, dynamic> toFirestore(Usuario usuario) {
    return {
      'nome': usuario.nome,
      'email': usuario.email,
      'foto': usuario.foto,
      'provider': usuario.provider.chave,
      'pessoaId': usuario.pessoaId,
    };
  }

  static Usuario fromFirestore(String uid, Map<String, dynamic> dados) {
    return Usuario(
      uid: uid,
      nome: dados['nome'] as String? ?? '',
      email: dados['email'] as String? ?? '',
      foto: dados['foto'] as String?,
      provider: AuthProvider.fromChave(dados['provider'] as String?),
      pessoaId: dados['pessoaId'] as String?,
    );
  }
}
