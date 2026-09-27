import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/usuario.dart';
import 'i_local_storage_service.dart';

/// Armazenamento local em SharedPreferences (itens 3.3 e 22).
final class SharedPrefLocalStorageService implements ILocalStorageService {
  static const String _chaveTema = 'preferencias.tema_escuro';
  static const String _chaveUsuario = 'sessao.cache_usuario';

  @override
  Future<void> salvarTemaEscuro(bool escuro) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chaveTema, escuro);
  }

  @override
  Future<bool?> lerTemaEscuro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_chaveTema);
  }

  @override
  Future<void> salvarCacheUsuario(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    // Só dados de exibição. Senha não é gravada aqui em hipótese alguma.
    await prefs.setString(
      _chaveUsuario,
      jsonEncode({
        'uid': usuario.uid,
        'nome': usuario.nome,
        'email': usuario.email,
        'foto': usuario.foto,
        'provider': usuario.provider.chave,
        'pessoaId': usuario.pessoaId,
      }),
    );
  }

  @override
  Future<Usuario?> lerCacheUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final bruto = prefs.getString(_chaveUsuario);
    if (bruto == null) return null;

    try {
      final mapa = jsonDecode(bruto) as Map<String, dynamic>;
      return Usuario(
        uid: mapa['uid'] as String,
        nome: mapa['nome'] as String? ?? '',
        email: mapa['email'] as String? ?? '',
        foto: mapa['foto'] as String?,
        provider: AuthProvider.fromChave(mapa['provider'] as String?),
        pessoaId: mapa['pessoaId'] as String?,
      );
    } catch (_) {
      // Cache corrompido não pode derrubar o app: basta ignorá-lo.
      return null;
    }
  }

  @override
  Future<void> limparCacheUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveUsuario);
  }
}
