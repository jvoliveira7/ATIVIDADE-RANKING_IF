import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_routes_constants.dart';
import '../../core/theme/theme_controller.dart';

/// Menu lateral (drawer) usado para navegar entre as telas principais
/// do app (item 11 da especificação: "tela principal com menu/drawer
/// lateral"). Também concentra o botão de alternância de tema
/// claro/escuro (item 10.7).
class AppDrawer extends StatelessWidget {
  final String rotaAtual;

  const AppDrawer({super.key, required this.rotaAtual});

  @override
  Widget build(BuildContext context) {
    final themeController = injector.get<ThemeController>();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _CabecalhoDrawer(),
            _ItemMenu(
              icone: Icons.groups_rounded,
              titulo: 'Alunos',
              selecionado: rotaAtual == AppRouteNames.home,
              onTap: () {
                Navigator.of(context).pop();
                context.goNamed(AppRouteNames.home);
              },
            ),
            _ItemMenu(
              icone: Icons.person_add_alt_1_rounded,
              titulo: 'Cadastrar aluno',
              selecionado: rotaAtual == AppRouteNames.cadastro,
              onTap: () {
                Navigator.of(context).pop();
                context.pushNamed(AppRouteNames.cadastro);
              },
            ),
            _ItemMenu(
              icone: Icons.emoji_events_rounded,
              titulo: 'Ranking',
              selecionado: rotaAtual == AppRouteNames.ranking,
              onTap: () {
                Navigator.of(context).pop();
                context.goNamed(AppRouteNames.ranking);
              },
            ),
            _ItemMenu(
              icone: Icons.info_outline_rounded,
              titulo: 'Sobre o app',
              selecionado: rotaAtual == AppRouteNames.sobre,
              onTap: () {
                Navigator.of(context).pop();
                context.goNamed(AppRouteNames.sobre);
              },
            ),
            const Spacer(),
            const Divider(),
            Watch((context) {
              final isDark = themeController.isDarkMode.value;
              return SwitchListTile(
                title: const Text('Tema escuro'),
                secondary: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                ),
                value: isDark,
                onChanged: (_) => themeController.toggleTheme(),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _CabecalhoDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 36, 20, 22),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.emoji_events_rounded, size: 28, color: colorScheme.secondary),
          ),
          const SizedBox(height: 12),
          Text(
            'HallIF',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onPrimary,
                ),
          ),
          Text(
            'IFPR · Campus Paranaguá',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.75),
                ),
          ),
        ],
      ),
    );
  }
}

class _ItemMenu extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final bool selecionado;
  final VoidCallback onTap;

  const _ItemMenu({
    required this.icone,
    required this.titulo,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icone),
      title: Text(titulo),
      selected: selecionado,
      selectedTileColor:
          Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
      onTap: onTap,
    );
  }
}
