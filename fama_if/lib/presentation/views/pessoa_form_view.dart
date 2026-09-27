import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/failure/failure.dart';
import '../../core/validators/empty_str_validator.dart';
import '../../domain/models/curso.dart';
import '../../domain/models/pessoa.dart';
import '../controllers/pessoa_viewmodel.dart';
import '../functions/ui_functions.dart';
import '../widgets/album_date_picker.dart';
import '../widgets/campos_pessoa.dart';
import '../widgets/input_text_field.dart';

/// Cadastro (item 14.5) e alteração (item 14.8) de pessoa. A mesma tela
/// atende aos dois casos, conforme receba ou não um [pessoaId].
///
/// Diferente da primeira parte, aqui não há campo de nota nenhum: as 15
/// estrelas passaram para a tela de avaliação, porque agora cada usuário dá
/// as suas próprias notas para a mesma pessoa.
class PessoaFormView extends StatefulWidget {
  final String? pessoaId;

  const PessoaFormView({super.key, this.pessoaId});

  bool get modoEdicao => pessoaId != null;

  @override
  State<PessoaFormView> createState() => _PessoaFormViewState();
}

class _PessoaFormViewState extends State<PessoaFormView> {
  late final PessoaViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _apelidoController = TextEditingController();

  Curso _curso = Curso.tads;
  int _turmaAno = DateTime.now().year;
  DateTime? _dataNascimento;

  bool _carregandoDadosIniciais = false;

  @override
  void initState() {
    super.initState();
    _viewModel = injector.get<PessoaViewModel>();

    if (widget.modoEdicao) {
      _carregandoDadosIniciais = true;
      _viewModel.commands
          .buscar(widget.pessoaId!)
          .then((_) => _preencherFormulario());
    }
  }

  void _preencherFormulario() {
    final pessoa = _viewModel.state.selecionada.value;
    if (pessoa == null || !mounted) return;

    setState(() {
      _nomeController.text = pessoa.nome;
      _apelidoController.text = pessoa.apelido;
      _curso = pessoa.curso;
      _turmaAno = pessoa.turmaAno;
      _dataNascimento = pessoa.dataNascimento;
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
      // `criadoPor` é preenchido pelo use case com o usuário autenticado; na
      // edição, o valor original é preservado lá também.
      final pessoa = Pessoa(
        id: widget.pessoaId ?? '',
        nome: _nomeController.text.trim(),
        apelido: _apelidoController.text.trim(),
        curso: _curso,
        turmaAno: _turmaAno,
        dataNascimento: _dataNascimento!,
        criadoPor: _viewModel.state.selecionada.value?.criadoPor ?? '',
      );

      final resultado = widget.modoEdicao
          ? await _viewModel.commands.alterar(pessoa)
          : await _viewModel.commands.cadastrar(pessoa);

      if (!mounted) return;

      resultado.fold(
        onSuccess: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.modoEdicao
                    ? 'Pessoa atualizada com sucesso!'
                    : 'Pessoa cadastrada com sucesso!',
              ),
            ),
          );
          context.pop();
        },
        onFailure: _mostrarErro,
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
        title: Text(widget.modoEdicao ? 'Editar pessoa' : 'Cadastrar pessoa'),
      ),
      body: _carregandoDadosIniciais
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const SecaoTitulo(
                    titulo: 'Dados da pessoa',
                    subtitulo: 'Cadastrar alguém aqui não cria conta de '
                        'acesso para essa pessoa.',
                  ),
                  const SizedBox(height: 16),
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
                  DropdownCurso(
                    valor: _curso,
                    onChanged: (v) => setState(() => _curso = v),
                  ),
                  const SizedBox(height: 16),
                  DropdownTurmaAno(
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
