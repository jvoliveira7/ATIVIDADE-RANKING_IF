import 'package:equatable/equatable.dart';

/// Forma de autenticação usada pelo usuário (itens 3.1 e 15).
enum AuthProvider {
  emailSenha,
  google;

  /// Valor gravado no campo `provider` do documento em `usuarios`.
  String get chave => switch (this) {
        AuthProvider.emailSenha => 'password',
        AuthProvider.google => 'google',
      };

  static AuthProvider fromChave(String? valor) {
    return AuthProvider.values.firstWhere(
      (p) => p.chave == valor,
      orElse: () => AuthProvider.emailSenha,
    );
  }
}

/// Usuário autenticado no app (item 5 da especificação).
///
/// É distinto de `Pessoa`: o usuário é quem faz login e avalia; a pessoa é
/// quem recebe avaliações. [pessoaId] guarda o vínculo entre os dois quando
/// o usuário também está cadastrado como pessoa avaliável — é esse campo que
/// sustenta o bloqueio de autoavaliação.
class Usuario extends Equatable {
  final String uid;
  final String nome;
  final String email;
  final String? foto;
  final AuthProvider provider;
  final String? pessoaId;

  const Usuario({
    required this.uid,
    required this.nome,
    required this.email,
    required this.provider,
    this.foto,
    this.pessoaId,
  });

  Usuario copyWith({
    String? nome,
    String? foto,
    String? pessoaId,
  }) {
    return Usuario(
      uid: uid,
      nome: nome ?? this.nome,
      email: email,
      provider: provider,
      foto: foto ?? this.foto,
      pessoaId: pessoaId ?? this.pessoaId,
    );
  }

  @override
  List<Object?> get props => [uid, nome, email, foto, provider, pessoaId];

  @override
  String toString() => 'Usuario(uid: $uid, nome: $nome, email: $email)';
}
