import 'package:flutter/material.dart';

import '../../core/routes/app_routes_constants.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/app_drawer.dart';

/// Tela "Sobre o App" (item 20): explica objetivo, contexto, critérios,
/// cálculo do Nível Lenda, os dois rankings e a infraestrutura usada.
class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o app')),
      drawer: const AppDrawer(rotaAtual: AppRouteNames.sobre),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _Capa(),
          const SizedBox(height: 24),
          const _Secao(
            icone: Icons.flag_rounded,
            titulo: 'O que é',
            texto: 'O PiramidGame IFPR-Pgua é um aplicativo desenvolvido em '
                'Flutter para fins didáticos. Ele permite cadastrar pessoas do '
                'IFPR – Campus Paranaguá e avaliá-las em critérios '
                'descontraídos de convivência, destaque e participação.',
          ),
          const _Secao(
            icone: Icons.star_rounded,
            titulo: 'Critérios e Nível Lenda',
            texto: 'Cada avaliação atribui notas de 1 a 5 estrelas em 15 '
                'categorias, como Resenha, Aura, Drip Escolar e Caos '
                'Controlado. A soma dessas notas forma o Nível Lenda, que vai '
                'de 15 a 75 pontos.',
          ),
          const _Secao(
            icone: Icons.person_search_rounded,
            titulo: 'Ranking pessoal',
            texto: 'Responde "na minha opinião, quem tem o maior Nível '
                'Lenda?". Considera exclusivamente as avaliações que você '
                'mesmo realizou — o que os outros usuários acharem não '
                'interfere nele.',
          ),
          const _Secao(
            icone: Icons.emoji_events_rounded,
            titulo: 'Ranking global',
            texto: 'Responde "na opinião dos usuários do aplicativo, quem tem '
                'o maior Nível Lenda?". Como a mesma pessoa pode ser avaliada '
                'por várias pessoas, a pontuação global é a média das '
                'avaliações recebidas, exibida junto com a quantidade de '
                'avaliações.',
          ),
          const _Secao(
            icone: Icons.block_rounded,
            titulo: 'Regras',
            texto: 'Ninguém pode avaliar a si próprio, e cada usuário tem uma '
                'única avaliação ativa para cada pessoa: para mudar de ideia, '
                'basta alterar a avaliação que já existe, em vez de criar '
                'outra.',
          ),
          const _Secao(
            icone: Icons.cloud_rounded,
            titulo: 'Onde ficam os dados',
            texto: 'Os dados são armazenados remotamente no Firestore e o '
                'acesso ao aplicativo usa o Firebase Authentication, com '
                'e-mail e senha ou conta Google. Por isso suas informações '
                'seguem disponíveis em outro aparelho, bastando entrar com a '
                'mesma conta.',
          ),
          const _Secao(
            icone: Icons.dark_mode_rounded,
            titulo: 'Aparência',
            texto: 'O aplicativo permite alternar entre tema claro e tema '
                'escuro em tempo de execução, pelo menu lateral. A preferência '
                'fica salva no aparelho.',
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'IFPR · Campus Paranaguá · TADS',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Capa extends StatelessWidget {
  const _Capa();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.ouroLenda, width: 3),
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 44,
                color: AppTheme.ouroLenda,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'PiramidGame IFPR-Pgua',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Ranking de Popularidade',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String texto;

  const _Secao({
    required this.icone,
    required this.titulo,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  texto,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.45,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.75),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
