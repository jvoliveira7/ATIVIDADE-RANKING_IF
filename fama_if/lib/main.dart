import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import 'core/di/dependency_injection.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Precisa vir antes da injeção de dependências: os services de Firestore e
  // de autenticação pegam as instâncias do Firebase assim que são criados.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  setupDependencyInjection();

  // O tema é resolvido antes do primeiro frame para o app não abrir no tema
  // claro e piscar para o escuro. Já a sessão é verificada pela própria tela
  // de splash, que é onde a especificação manda checar a autenticação
  // (item 18) — por isso ela não é aguardada aqui.
  await injector.get<ThemeController>().carregarPreferencia();

  runApp(const PiramidGameApp());
}

/// Widget raiz do PiramidGame IFPR-Pgua.
class PiramidGameApp extends StatelessWidget {
  const PiramidGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = injector.get<ThemeController>();

    // `Watch` reconstrói o MaterialApp sempre que `themeMode` muda, aplicando
    // a troca de tema em tempo de execução (item 14.15).
    return Watch((context) {
      return MaterialApp.router(
        title: 'PiramidGame IFPR-Pgua',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeController.themeMode.value,
        routerConfig: goRouter,
      );
    });
  }
}
