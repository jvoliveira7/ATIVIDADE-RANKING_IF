/// Contrato do repositório de preferências locais (itens 4.2 e 22).
abstract interface class IPreferenceRepository {
  Future<void> salvarTemaEscuro(bool escuro);
  Future<bool?> lerTemaEscuro();
}
