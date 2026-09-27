import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/validators/empty_str_validator.dart';
import '../controllers/auth_viewmodel.dart';
import '../functions/ui_functions.dart';
import '../widgets/aviso_erro.dart';
import '../widgets/input_text_field.dart';

/// Cadastro de usuário (itens 3.1 e 14.1): cria a conta no Firebase
/// Authentication com e-mail e senha.
///
/// Os dados da pessoa avaliável não são pedidos aqui — eles vêm no passo
/// seguinte, em "completar perfil", que vale também para quem entra com
/// Google e por isso não pode depender deste formulário.
class CadastroUsuarioView extends StatefulWidget {
  const CadastroUsuarioView({super.key});

  @override
  State<CadastroUsuarioView> createState() => _CadastroUsuarioViewState();
}

class _CadastroUsuarioViewState extends State<CadastroUsuarioView> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmaSenhaController = TextEditingController();

  late final AuthViewModel _viewModel;
  bool _senhaVisivel = false;

  @override
  void initState() {
    super.initState();
    _viewModel = injector.get<AuthViewModel>();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmaSenhaController.dispose();
    super.dispose();
  }

  Future<void> _criarConta() async {
    if (!_formKey.currentState!.validate()) return;

    // Criada a conta, o `redirect` leva sozinho para completar o perfil.
    await _viewModel.commands.criarConta(
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      senha: _senhaController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Watch((context) {
                final carregando = _viewModel.state.carregando.value;
                final mensagem = _viewModel.state.mensagem.value;

                return Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InputTextField(
                        label: 'Nome',
                        controller: _nomeController,
                        prefixIcon: Icons.person_rounded,
                        textInputAction: TextInputAction.next,
                        enabled: !carregando,
                        validator: (value) =>
                            validateField(value, [EmptyStrValidator()]),
                      ),
                      const SizedBox(height: 14),
                      InputTextField(
                        label: 'E-mail',
                        controller: _emailController,
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        enabled: !carregando,
                        validator: (valor) {
                          final texto = valor?.trim() ?? '';
                          if (texto.isEmpty) return 'Informe seu e-mail.';
                          if (!texto.contains('@')) return 'E-mail inválido.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      InputTextField(
                        label: 'Senha',
                        controller: _senhaController,
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: !_senhaVisivel,
                        textInputAction: TextInputAction.next,
                        enabled: !carregando,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _senhaVisivel
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                          ),
                          onPressed: () =>
                              setState(() => _senhaVisivel = !_senhaVisivel),
                        ),
                        validator: (valor) {
                          // Mínimo exigido pelo próprio Firebase.
                          if (valor == null || valor.length < 6) {
                            return 'A senha precisa ter ao menos 6 caracteres.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      InputTextField(
                        label: 'Confirmar senha',
                        controller: _confirmaSenhaController,
                        prefixIcon: Icons.lock_reset_rounded,
                        obscureText: !_senhaVisivel,
                        textInputAction: TextInputAction.done,
                        enabled: !carregando,
                        onFieldSubmitted: (_) => _criarConta(),
                        validator: (valor) => valor != _senhaController.text
                            ? 'As senhas não conferem.'
                            : null,
                      ),
                      if (mensagem != null) ...[
                        const SizedBox(height: 16),
                        AvisoErro(mensagem: mensagem),
                      ],
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: carregando ? null : _criarConta,
                        icon: carregando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.person_add_alt_1_rounded),
                        label: Text(
                          carregando ? 'Criando conta...' : 'Criar conta',
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
