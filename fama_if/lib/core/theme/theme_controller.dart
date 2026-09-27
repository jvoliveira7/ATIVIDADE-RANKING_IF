import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../domain/usecases/i_preference_usecases.dart';

/// Controla o tema claro/escuro em tempo de execução (item 14.15) e guarda a
/// escolha no armazenamento local, que é um dos usos permitidos para o
/// SharedPreferences (item 22).
class ThemeController {
  final IAlterarTemaUseCase _alterarTema;
  final ICarregarTemaUseCase _carregarTema;

  final themeMode = signal<ThemeMode>(ThemeMode.light);

  late final isDarkMode = computed(() => themeMode.value == ThemeMode.dark);

  ThemeController({
    required IAlterarTemaUseCase alterarTema,
    required ICarregarTemaUseCase carregarTema,
  })  : _alterarTema = alterarTema,
        _carregarTema = carregarTema;

  /// Lê a preferência salva. Chamado na inicialização, antes do `runApp`,
  /// para o app não abrir no tema claro e piscar para o escuro em seguida.
  Future<void> carregarPreferencia() async {
    final resultado = await _carregarTema(());
    resultado.fold(
      onSuccess: (escuro) =>
          themeMode.value = escuro ? ThemeMode.dark : ThemeMode.light,
      onFailure: (_) => themeMode.value = ThemeMode.light,
    );
  }

  Future<void> toggleTheme() async {
    final escuro = themeMode.value != ThemeMode.dark;
    themeMode.value = escuro ? ThemeMode.dark : ThemeMode.light;
    await _alterarTema((escuro: escuro));
  }
}
