import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/validators/empty_str_validator.dart';
import '../../domain/models/curso.dart';
import '../controllers/auth_viewmodel.dart';
import '../functions/ui_functions.dart';
import '../widgets/album_date_picker.dart';
import '../widgets/aviso_erro.dart';
import '../widgets/campos_pessoa.dart';
import '../widgets/input_text_field.dart';

/// Completar perfil: cria a pessoa que representa o usuário autenticado e
/// grava o vínculo entre os dois (item 5).
///
/// Sem esse vínculo o sistema não teria como saber quem é quem e a proibição
/// de autoavaliação (itens 9 e 14.12) ficaria sem base. Vale para as duas
/// formas de login, já que o Google devolve apenas nome, e-mail e foto —
/// nunca curso, turma ou data de nascimento.
class CompletarPerfilView extends StatefulWidget {
  const CompletarPerfilView({super.key});

  @override
  State<CompletarPerfilView> createState() => _CompletarPerfilViewState();
}

class _CompletarPerfilViewState extends State<CompletarPerfilView> {
  final _formKey = GlobalKey<FormState>();
  final _apelidoController = TextEditingController();

  late final AuthViewModel _viewModel;

  Curso _curso = Curso.tads;
  int _turmaAno = DateTime.now().year;
  DateTime? _dataNascimento;

  @override
  void initState() {
    super.initState();
    _viewModel = injector.get<AuthViewModel>();
  }

  @override
  void dispose() {
    _apelidoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dataNascimento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione sua data de nascimento.')),
      );
      return;
    }

    // Concluído o perfil, o `redirect` do go_router libera a área principal.
    await _viewModel.commands.completarPerfil((
      apelido: _apelidoController.text.trim(),
      curso: _curso,
      turmaAno: _turmaAno,
      dataNascimento: _dataNascimento!,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completar perfil'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _viewModel.commands.logout(),
          ),
        ],
      ),
      body: Watch((context) {
        final carregando = _viewModel.state.carregando.value;
        final mensagem = _viewModel.state.mensagem.value;
        final usuario = _viewModel.state.usuario.value;

        return Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SecaoTitulo(
                titulo: 'Quase lá, ${usuario?.nome.split(' ').first ?? ''}!',
                subtitulo: 'Esses dados criam o seu perfil no campus e '
                    'impedem que você avalie a si próprio.',
              ),
              const SizedBox(height: 20),
              InputTextField(
                label: 'Apelido',
                controller: _apelidoController,
                prefixIcon: Icons.badge_rounded,
                enabled: !carregando,
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
              if (mensagem != null) ...[
                const SizedBox(height: 16),
                AvisoErro(mensagem: mensagem),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: carregando ? null : _salvar,
                icon: carregando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded),
                label: const Text('Entrar no PiramidGame'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }
}
