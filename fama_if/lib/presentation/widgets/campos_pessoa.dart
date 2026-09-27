import 'package:flutter/material.dart';

import '../../domain/models/curso.dart';

/// Campos de seleção do cadastro de pessoa (item 8.3), compartilhados entre o
/// formulário de pessoas e a tela de completar perfil. Curso e turma/ano são
/// seleção, nunca digitação livre (itens 8.1 e 8.2).

class SecaoTitulo extends StatelessWidget {
  final String titulo;
  final String? subtitulo;

  const SecaoTitulo({super.key, required this.titulo, this.subtitulo});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (subtitulo != null)
          Text(
            subtitulo!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
      ],
    );
  }
}

class DropdownCurso extends StatelessWidget {
  final Curso valor;
  final ValueChanged<Curso> onChanged;

  const DropdownCurso({
    super.key,
    required this.valor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Curso>(
      initialValue: valor,
      decoration: const InputDecoration(
        labelText: 'Curso',
        prefixIcon: Icon(Icons.menu_book_rounded),
        border: OutlineInputBorder(),
      ),
      items: Curso.values
          .map((c) => DropdownMenuItem(value: c, child: Text(c.displayName)))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class DropdownTurmaAno extends StatelessWidget {
  final int valor;
  final ValueChanged<int> onChanged;

  const DropdownTurmaAno({
    super.key,
    required this.valor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Intervalo fixado pela especificação (item 8.2).
    final anos = [for (var a = 2026; a >= 1998; a--) a];

    return DropdownButtonFormField<int>(
      initialValue: valor,
      decoration: const InputDecoration(
        labelText: 'Turma/ano',
        prefixIcon: Icon(Icons.calendar_today_rounded),
        border: OutlineInputBorder(),
      ),
      items: anos
          .map((ano) => DropdownMenuItem(value: ano, child: Text('$ano')))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
