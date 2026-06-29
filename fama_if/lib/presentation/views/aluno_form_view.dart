import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/failure/failure.dart';
import '../../core/routes/app_routes_constants.dart';
import '../../core/validators/empty_str_validator.dart';
import '../../domain/models/aluno.dart';
import '../../domain/models/criterios_popularidade.dart';
import '../../domain/models/curso.dart';
import '../controllers/aluno_viewmodel.dart';
import '../functions/ui_functions.dart';
import '../widgets/album_date_picker.dart';
import '../widgets/criterio_slider.dart';
import '../widgets/input_text_field.dart';

/// Tela de cadastro (item 10.1) e alteração (item 10.4) de aluno.
/// A mesma tela atende aos dois casos: se [alunoId] for informado, ela
/// carrega os dados do aluno existente e entra em modo edição; caso
/// contrário, inicia um cadastro novo com valores padrão.
class AlunoFormView extends StatefulWidget {
  final String? alunoId;

  const AlunoFormView({super.key, this.alunoId});

  bool get modoEdicao => alunoId != null;

  @override
  State<AlunoFormView> createState() => _AlunoFormViewState();
}

class _AlunoFormViewState extends State<AlunoFormView> {
  late final AlunoViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _apelidoController = TextEditingController();

  Curso _curso = Curso.tads;
  int _turmaAno = DateTime.now().year;
  DateTime? _dataNascimento;
  CriteriosPopularidade _criterios = CriteriosPopularidade.inicial();

  bool _carregandoDadosIniciais = false;

  @override
  void initState() {
    super.initState();
    _viewModel = injector.get<AlunoViewModel>();

    if (widget.modoEdicao) {
      _carregandoDadosIniciais = true;
      _viewModel.commands
          .buscarAlunoPorId(widget.alunoId!)
          .then((_) => _preencherFormularioComAlunoCarregado());
    }
  }

  void _preencherFormularioComAlunoCarregado() {
    final aluno = _viewModel.state.alunoSelecionado.value;
    if (aluno == null || !mounted) return;
    setState(() {
      _nomeController.text = aluno.nome;
      _apelidoController.text = aluno.apelido;
      _curso = aluno.curso;
      _turmaAno = aluno.turmaAno;
      _dataNascimento = aluno.dataNascimento;
      _criterios = aluno.criterios;
      _carregandoDadosIniciais = false;
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _apelidoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dataNascimento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data de nascimento.')),
      );
      return;
    }

    try {
      final aluno = Aluno(
        id: widget.alunoId ?? '',
        nome: _nomeController.text.trim(),
        curso: _curso,
        turmaAno: _turmaAno,
        apelido: _apelidoController.text.trim(),
        dataNascimento: _dataNascimento!,
        criterios: _criterios,
      );

      final resultado = widget.modoEdicao
          ? await _viewModel.commands.alterarAluno(aluno)
          : await _viewModel.commands.cadastrarAluno(aluno);

      if (!mounted) return;

      resultado.fold(
        onSuccess: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.modoEdicao
                    ? 'Aluno atualizado com sucesso!'
                    : 'Aluno cadastrado com sucesso!',
              ),
            ),
          );
          context.goNamed(AppRouteNames.home);
        },
        onFailure: (falha) => _mostrarErro(falha),
      );
    } on Failure catch (falha) {
      _mostrarErro(falha);
    }
  }

  void _mostrarErro(Failure falha) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(falha.msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.modoEdicao ? 'Editar aluno' : 'Cadastrar aluno'),
      ),
      body: _carregandoDadosIniciais
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _SecaoTitulo(titulo: 'Dados básicos'),
                  const SizedBox(height: 12),
                  InputTextField(
                    label: 'Nome',
                    controller: _nomeController,
                    prefixIcon: Icons.person_rounded,
                    validator: (value) =>
                        validateField(value, [EmptyStrValidator()]),
                  ),
                  const SizedBox(height: 16),
                  InputTextField(
                    label: 'Apelido',
                    controller: _apelidoController,
                    prefixIcon: Icons.badge_rounded,
                    validator: (value) =>
                        validateField(value, [EmptyStrValidator()]),
                  ),
                  const SizedBox(height: 16),
                  _DropdownCurso(
                    valor: _curso,
                    onChanged: (v) => setState(() => _curso = v),
                  ),
                  const SizedBox(height: 16),
                  _DropdownTurmaAno(
                    valor: _turmaAno,
                    onChanged: (v) => setState(() => _turmaAno = v),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: AlbumDatePicker(
                        dataInicial: _dataNascimento,
                        onDataSelecionada: (data) =>
                            setState(() => _dataNascimento = data),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SecaoTitulo(
                    titulo: 'Critérios de popularidade',
                    subtitulo:
                        'Nível Lenda atual: ${_criterios.nivelLenda} pontos',
                  ),
                  const SizedBox(height: 8),
                  ..._criterios.items.map(
                    (item) => CriterioSlider(
                      nome: item.nome,
                      descricao: item.descricao,
                      valor: item.getValue(_criterios),
                      onChanged: (novoValor) => setState(() {
                        _criterios = item.setValue(_criterios, novoValor);
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Watch((context) {
                    final salvando = _viewModel.state.carregando.value;
                    return FilledButton.icon(
                      onPressed: salvando ? null : _salvar,
                      icon: salvando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_rounded),
                      label: Text(
                        widget.modoEdicao ? 'Salvar alterações' : 'Cadastrar',
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

class _SecaoTitulo extends StatelessWidget {
  final String titulo;
  final String? subtitulo;

  const _SecaoTitulo({required this.titulo, this.subtitulo});

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

class _DropdownCurso extends StatelessWidget {
  final Curso valor;
  final ValueChanged<Curso> onChanged;

  const _DropdownCurso({required this.valor, required this.onChanged});

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

class _DropdownTurmaAno extends StatelessWidget {
  final int valor;
  final ValueChanged<int> onChanged;

  const _DropdownTurmaAno({required this.valor, required this.onChanged});

  @override
  Widget build(BuildContext context) {
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
