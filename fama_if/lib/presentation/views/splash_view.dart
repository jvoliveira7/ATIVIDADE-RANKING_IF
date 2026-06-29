import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_routes_constants.dart';
import '../../core/theme/app_theme.dart';

/// Tela de Splash, exibida ao abrir o app (item 12 da especificação).
/// Após um pequeno tempo, redireciona automaticamente para o Ranking,
/// que agora funciona como dashboard inicial do app (com destaque para
/// o pódio/Top 3 geral de popularidade).
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.goNamed(AppRouteNames.ranking);
    });
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
              'HallIF',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppTheme.papel,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ranking de Popularidade dos Alunos',
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
          ],
        ),
      ),
    );
  }
}
