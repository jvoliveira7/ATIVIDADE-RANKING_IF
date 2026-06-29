import 'package:flutter/material.dart';

import '../../core/routes/app_routes_constants.dart';
import '../widgets/app_drawer.dart';

/// Tela "Sobre o App", obrigatória pela especificação (item 13).
/// Explica o objetivo do app, o contexto institucional, os critérios e
/// o cálculo do Nível Lenda, além de informar sobre armazenamento local
/// e tema claro/escuro.
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
          const _Secao(
            icone: Icons.flag_rounded,
            titulo: 'Objetivo',
            texto:
                'O HallIF (Ranking de Popularidade dos Alunos) é um aplicativo '
                'desenvolvido em Flutter para fins didáticos. Ele permite '
                'cadastrar alunos do IFPR - Campus Paranaguá e avaliá-los em '
                'critérios descontraídos de convivência, destaque e '
                'participação na turma.',
          ),
          const _Secao(
            icone: Icons.school_rounded,
            titulo: 'Contexto',
            texto:
                'O app foi pensado para o contexto institucional do IFPR - '
                'Campus Paranaguá, vinculando cada aluno cadastrado a um '
                'curso e a uma turma/ano.',
          ),
          const _Secao(
            icone: Icons.star_rounded,
            titulo: 'Critérios de avaliação',
            texto:
                'Cada aluno recebe notas de 1 a 5 em 15 categorias, como '
                'Resenha, Aura, Carisma Natural e Cérebro Turbo, entre '
                'outras. A soma dessas notas forma o Nível Lenda, usado '
                'para organizar o ranking geral.',
          ),
          const _Secao(
            icone: Icons.emoji_events_rounded,
            titulo: 'Cálculo do Nível Lenda',
            texto:
                'São 15 critérios, cada um valendo de 1 a 5 pontos. Por '
                'isso, o Nível Lenda de um aluno varia de 15 (mínimo) a 75 '
                'pontos (máximo). O ranking é ordenado automaticamente do '
                'maior para o menor Nível Lenda.',
          ),
          const _Secao(
            icone: Icons.storage_rounded,
            titulo: 'Armazenamento dos dados',
            texto:
                'Todos os dados são armazenados localmente no dispositivo, '
                'utilizando o SharedPreferences. Nenhuma informação é '
                'enviada para a internet.',
          ),
          const _Secao(
            icone: Icons.dark_mode_rounded,
            titulo: 'Tema claro e escuro',
            texto:
                'O aplicativo permite alternar entre tema claro e tema '
                'escuro em tempo de execução, através do menu lateral.',
          ),
        ],
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
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(texto, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
