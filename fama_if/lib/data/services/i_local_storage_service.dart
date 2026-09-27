import '../../domain/models/usuario.dart';

/// Contrato do armazenamento local auxiliar (itens 3.3 e 22).
///
/// Restrito a preferências e cache. **Nunca** guarda senha, lista de pessoas,
/// avaliações ou ranking — esses vivem no Firestore. O cache do usuário existe
/// só para a interface conseguir mostrar nome e foto imediatamente ao abrir o
/// app; quem decide se a sessão é válida é sempre o Firebase Authentication.
abstract interface class ILocalStorageService {
  Future<void> salvarTemaEscuro(bool escuro);
  Future<bool?> lerTemaEscuro();

  Future<void> salvarCacheUsuario(Usuario usuario);
  Future<Usuario?> lerCacheUsuario();
  Future<void> limparCacheUsuario();
}
