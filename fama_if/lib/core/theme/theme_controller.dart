import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Controla o tema (claro/escuro) do aplicativo em tempo de execução
class ThemeController {
  final themeMode = signal<ThemeMode>(ThemeMode.light);

  late final isDarkMode = computed(() => themeMode.value == ThemeMode.dark);

  void toggleTheme() {
    themeMode.value =
        themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}
