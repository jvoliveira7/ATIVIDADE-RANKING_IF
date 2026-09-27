import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_routes_constants.dart';
import '../../core/theme/theme_controller.dart';
import '../controllers/auth_viewmodel.dart';

/// Menu lateral da área autenticada (item 24): pessoas, os dois rankings,
/// sobre, alternância de tema e logout.
class AppDrawer extends StatelessWidget {
  final String rotaAtual;

  const AppDrawer({super.key, required this.rotaAtual});

  @override
  Widget build(BuildContext context) {
    final themeController = injector.get<ThemeController>();
    final authViewModel = injector.get<AuthViewModel>();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const _CabecalhoDrawer(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _ItemMenu(
                    icone: Icons.groups_rounded,
                    titulo: 'Pessoas',
                    selecionado: rotaAtual == AppRouteNames.pessoas,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.goNamed(AppRouteNames.pessoas);
                    },
                  ),
                  _ItemMenu(
                    icone: Icons.person_add_alt_1_rounded,
                    titulo: 'Cadastrar pessoa',
                    selecionado: rotaAtual == AppRouteNames.pessoaForm,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.pushNamed(AppRouteNames.pessoaForm);
                    },
                  ),
                  const Divider(),
                  _ItemMenu(
                    icone: Icons.person_search_rounded,
                    titulo: 'Ranking pessoal',
                    subtitulo: 'Na minha opinião',
                    selecionado: rotaAtual == AppRouteNames.rankingPessoal,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.goNamed(AppRouteNames.rankingPessoal);
                    },
                  ),
                  _ItemMenu(
                    icone: Icons.emoji_events_rounded,
                    titulo: 'Ranking global',
                    subtitulo: 'Na opinião do campus',
                    selecionado: rotaAtual == AppRouteNames.rankingGlobal,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.goNamed(AppRouteNames.rankingGlobal);
                    },
                  ),
                  const Divider(),
                  _ItemMenu(
                    icone: Icons.info_outline_rounded,
                    titulo: 'Sobre o app',
                    selecionado: rotaAtual == AppRouteNames.sobre,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.goNamed(AppRouteNames.sobre);
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
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
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: const Text('Sair'),
              // Não navega: ao encerrar a sessão o `redirect` do go_router
              // leva para o login sozinho (item 14.4).
              onTap: () async {
                Navigator.of(context).pop();
                await authViewModel.commands.logout();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Cabeçalho com os dados do usuário autenticado, para deixar visível de quem
/// é a sessão em uso.
class _CabecalhoDrawer extends StatelessWidget {
  const _CabecalhoDrawer();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authViewModel = injector.get<AuthViewModel>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Watch((context) {
        final usuario = authViewModel.state.usuario.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: colorScheme.onPrimary.withValues(alpha: 0.15),
                  backgroundImage: usuario?.foto != null
                      ? NetworkImage(usuario!.foto!)
                      : null,
                  child: usuario?.foto == null
                      ? Icon(
                          Icons.emoji_events_rounded,
                          color: colorScheme.secondary,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        usuario?.nome.isNotEmpty == true
                            ? usuario!.nome
                            : 'PiramidGame',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: colorScheme.onPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        usuario?.email ?? 'IFPR · Campus Paranaguá',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onPrimary
                                  .withValues(alpha: 0.75),
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class _ItemMenu extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String? subtitulo;
  final bool selecionado;
  final VoidCallback onTap;

  const _ItemMenu({
    required this.icone,
    required this.titulo,
    required this.selecionado,
    required this.onTap,
    this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icone),
      title: Text(titulo),
      subtitle: subtitulo != null ? Text(subtitulo!) : null,
      selected: selecionado,
      selectedTileColor:
          Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
      onTap: onTap,
    );
  }
}
