import 'package:flutter/material.dart';

/// Widget customizado para selecionar a data de nascimento (item 6.3 da
/// especificação), em formato de "seletor de álbum": o usuário avança em
/// 3 etapas (Década → Ano → Mês → Dia), cada uma exibida como uma grade
/// de opções tocáveis, ao invés de abrir um calendário ou modal.
///
/// É deliberadamente diferente tanto do `showDatePicker` padrão do
/// Flutter quanto do `DateWheelPicker` (roletas) visto no projeto de
/// referência do professor.
class AlbumDatePicker extends StatefulWidget {
  final DateTime? dataInicial;
  final ValueChanged<DateTime> onDataSelecionada;

  const AlbumDatePicker({
    super.key,
    this.dataInicial,
    required this.onDataSelecionada,
  });

  @override
  State<AlbumDatePicker> createState() => _AlbumDatePickerState();
}

enum _Etapa { decada, ano, mes, dia }

class _AlbumDatePickerState extends State<AlbumDatePicker> {
  late _Etapa _etapa;
  int? _decadaSelecionada;
  int? _anoSelecionado;
  int? _mesSelecionado;
  int? _diaSelecionado;

  static const _anoMinimo = 1950;
  static final _anoMaximo = DateTime.now().year;

  static const _nomesMeses = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];

  @override
  void initState() {
    super.initState();
    final inicial = widget.dataInicial;
    if (inicial != null) {
      _decadaSelecionada = (inicial.year ~/ 10) * 10;
      _anoSelecionado = inicial.year;
      _mesSelecionado = inicial.month;
      _diaSelecionado = inicial.day;
      _etapa = _Etapa.dia;
    } else {
      _etapa = _Etapa.decada;
    }
  }

  List<int> get _decadas {
    final decadaMin = (_anoMinimo ~/ 10) * 10;
    final decadaMax = (_anoMaximo ~/ 10) * 10;
    return [for (var d = decadaMax; d >= decadaMin; d -= 10) d];
  }

  List<int> get _anosDaDecada {
    final inicio = _decadaSelecionada!;
    final fim = (inicio + 9).clamp(_anoMinimo, _anoMaximo);
    return [for (var a = fim; a >= inicio && a >= _anoMinimo; a--) a];
  }

  int get _diasNoMes {
    return DateTime(_anoSelecionado!, _mesSelecionado! + 1, 0).day;
  }

  void _confirmarSeDataCompleta() {
    if (_anoSelecionado != null &&
        _mesSelecionado != null &&
        _diaSelecionado != null) {
      widget.onDataSelecionada(
        DateTime(_anoSelecionado!, _mesSelecionado!, _diaSelecionado!),
      );
    }
  }

  String get _resumoSelecionado {
    if (_diaSelecionado != null && _mesSelecionado != null && _anoSelecionado != null) {
      final dia = _diaSelecionado!.toString().padLeft(2, '0');
      return '$dia/${_nomesMeses[_mesSelecionado! - 1]}/$_anoSelecionado';
    }
    if (_mesSelecionado != null && _anoSelecionado != null) {
      return '${_nomesMeses[_mesSelecionado! - 1]}/$_anoSelecionado';
    }
    if (_anoSelecionado != null) return '$_anoSelecionado';
    if (_decadaSelecionada != null) return 'Década de $_decadaSelecionada';
    return 'Selecione a data de nascimento';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (_etapa != _Etapa.decada)
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: 'Voltar',
                color: Theme.of(context).colorScheme.primary,
                onPressed: () => setState(() {
                  _etapa = switch (_etapa) {
                    _Etapa.ano => _Etapa.decada,
                    _Etapa.mes => _Etapa.ano,
                    _Etapa.dia => _Etapa.mes,
                    _Etapa.decada => _Etapa.decada,
                  };
                }),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DATA DE NASCIMENTO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.45),
                    ),
                  ),
                  Text(
                    _resumoSelecionado,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        _TrilhaEtapas(etapaAtual: _etapa),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _buildGrade(),
        ),
      ],
    );
  }

  Widget _buildGrade() {
    switch (_etapa) {
      case _Etapa.decada:
        return _Grade(
          key: const ValueKey('decada'),
          itens: _decadas.map((d) => '${d}s').toList(),
          onSelecionado: (index) => setState(() {
            _decadaSelecionada = _decadas[index];
            _etapa = _Etapa.ano;
          }),
        );
      case _Etapa.ano:
        return _Grade(
          key: const ValueKey('ano'),
          itens: _anosDaDecada.map((a) => '$a').toList(),
          onSelecionado: (index) => setState(() {
            _anoSelecionado = _anosDaDecada[index];
            _etapa = _Etapa.mes;
          }),
        );
      case _Etapa.mes:
        return _Grade(
          key: const ValueKey('mes'),
          itens: _nomesMeses,
          colunas: 3,
          onSelecionado: (index) => setState(() {
            _mesSelecionado = index + 1;
            _etapa = _Etapa.dia;
          }),
        );
      case _Etapa.dia:
        return _Grade(
          key: const ValueKey('dia'),
          itens: List.generate(_diasNoMes, (i) => '${i + 1}'),
          colunas: 7,
          itemSelecionado: _diaSelecionado != null ? _diaSelecionado! - 1 : null,
          onSelecionado: (index) => setState(() {
            _diaSelecionado = index + 1;
            _confirmarSeDataCompleta();
          }),
        );
    }
  }
}

/// Indicador visual das 4 etapas do seletor (Década → Ano → Mês → Dia),
/// mostrando em qual etapa o usuário está através de pontos conectados
/// por uma linha — reforça que é um processo em sequência, sem ocupar
/// o espaço de um texto.
class _TrilhaEtapas extends StatelessWidget {
  final _Etapa etapaAtual;

  const _TrilhaEtapas({required this.etapaAtual});

  @override
  Widget build(BuildContext context) {
    final indiceAtual = _Etapa.values.indexOf(etapaAtual);
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: List.generate(_Etapa.values.length * 2 - 1, (i) {
        if (i.isOdd) {
          // segmento de linha entre dois pontos
          final indiceAnterior = i ~/ 2;
          final ativo = indiceAnterior < indiceAtual;
          return Expanded(
            child: Container(
              height: 2,
              color: ativo
                  ? colorScheme.secondary
                  : colorScheme.onSurface.withValues(alpha: 0.12),
            ),
          );
        }
        final indice = i ~/ 2;
        final concluido = indice < indiceAtual;
        final atual = indice == indiceAtual;
        return Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (concluido || atual)
                ? colorScheme.secondary
                : colorScheme.onSurface.withValues(alpha: 0.15),
          ),
        );
      }),
    );
  }
}

/// Grade de opções tocáveis reutilizada em cada etapa do [AlbumDatePicker].
/// Visualmente trata cada opção como uma "ficha" tocável: cantos
/// arredondados generosos, leve relevo, e destaque dourado (cor de
/// medalha) para o item selecionado.
class _Grade extends StatelessWidget {
  final List<String> itens;
  final int colunas;
  final int? itemSelecionado;
  final ValueChanged<int> onSelecionado;

  const _Grade({
    super.key,
    required this.itens,
    required this.onSelecionado,
    this.colunas = 4,
    this.itemSelecionado,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: colunas,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: itens.length,
      itemBuilder: (context, index) {
        final selecionado = index == itemSelecionado;
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onSelecionado(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selecionado
                  ? colorScheme.secondary
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: selecionado
                  ? null
                  : Border.all(color: colorScheme.onSurface.withValues(alpha: 0.06)),
            ),
            child: Text(
              itens[index],
              style: TextStyle(
                fontWeight: selecionado ? FontWeight.w800 : FontWeight.w600,
                fontSize: 13,
                color: selecionado ? colorScheme.onSecondary : colorScheme.onSurface,
              ),
            ),
          ),
        );
      },
    );
  }
}
