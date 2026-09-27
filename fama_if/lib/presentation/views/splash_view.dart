import 'package:flutter/material.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/auth_viewmodel.dart';

/// Tela de Splash (item 18).
///
/// É aqui que o app verifica o estado da autenticação. Enquanto a verificação
/// não termina, a sessão fica com status `desconhecido` e o `redirect` do
/// go_router segura todo mundo nesta tela; assim que o resultado chega, ele
/// encaminha para a área principal ou para o login, sem esta tela precisar
/// navegar por conta própria.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _verificarSessao();
  }

  Future<void> _verificarSessao() async {
    // Uma pausa curta para a splash não aparecer como um flash na tela de
    // quem já está logado.
    await Future.delayed(const Duration(milliseconds: 1500));
    await injector.get<AuthViewModel>().commands.verificarSessao();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.roxoRecreio,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.ouroLenda, width: 4),
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 64,
                color: AppTheme.ouroLenda,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'PiramidGame',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppTheme.papel,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Quem é lenda no campus?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.papel,
                  ),
            ),
            Text(
              'IFPR · Campus Paranaguá',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.papel.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: AppTheme.ouroLenda,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Verificando sua sessão...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.papel.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
