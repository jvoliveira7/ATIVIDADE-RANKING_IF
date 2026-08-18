import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/di/dependency_injection.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  setupDependencyInjection();
  runApp(const HallIfApp());
}

/// Widget raiz do app HallIF
class HallIfApp extends StatelessWidget {
  const HallIfApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = injector.get<ThemeController>();

    // `Watch` reconstrói o MaterialApp.router sempre que `themeMode`
    // mudar, aplicando o tema claro/escuro em tempo de execute
    return Watch((context) {
      return MaterialApp.router(
        title: 'HallIf',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeController.themeMode.value,
        routerConfig: goRouter,
      );
    });
  }
}
