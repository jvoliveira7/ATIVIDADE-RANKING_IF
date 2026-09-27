import '../services/i_local_storage_service.dart';
import 'i_preference_repository.dart';

/// Repositório das preferências locais, hoje só o tema (itens 4.2 e 22).
final class PreferenceRepositoryImpl implements IPreferenceRepository {
  final ILocalStorageService _localStorage;

  PreferenceRepositoryImpl({required ILocalStorageService localStorage})
      : _localStorage = localStorage;

  @override
  Future<void> salvarTemaEscuro(bool escuro) =>
      _localStorage.salvarTemaEscuro(escuro);

  @override
  Future<bool?> lerTemaEscuro() => _localStorage.lerTemaEscuro();
}
