import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_routes_constants.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/auth_viewmodel.dart';
import '../widgets/aviso_erro.dart';
import '../widgets/input_text_field.dart';

/// Tela de Login (item 19): e-mail, senha, Entrar, Criar conta e Entrar com
/// Google. Os erros de autenticação são exibidos ao usuário, já traduzidos
/// para português pela camada de service.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  late final AuthViewModel _viewModel;
  bool _senhaVisivel = false;

  @override
  void initState() {
    super.initState();
    _viewModel = injector.get<AuthViewModel>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    await _viewModel.commands.login(
      _emailController.text.trim(),
      _senhaController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      const _Cabecalho(),
                      const SizedBox(height: 32),
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
                        textInputAction: TextInputAction.done,
                        enabled: !carregando,
                        onFieldSubmitted: (_) => _entrar(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _senhaVisivel
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                          ),
                          onPressed: () =>
                              setState(() => _senhaVisivel = !_senhaVisivel),
                        ),
                        validator: (valor) =>
                            (valor == null || valor.isEmpty)
                                ? 'Informe sua senha.'
                                : null,
                      ),
                      if (mensagem != null) ...[
                        const SizedBox(height: 16),
                        AvisoErro(mensagem: mensagem),
                      ],
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: carregando ? null : _entrar,
                        icon: carregando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.login_rounded),
                        label: Text(carregando ? 'Entrando...' : 'Entrar'),
                      ),
                      const SizedBox(height: 12),
                      const _SeparadorOu(),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: carregando
                            ? null
                            : () => _viewModel.commands.loginComGoogle(),
                        icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                        label: const Text('Entrar com Google'),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: carregando
                            ? null
                            : () => context
                                .pushNamed(AppRouteNames.cadastroUsuario),
                        child: const Text('Não tem conta? Criar conta'),
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

class _Cabecalho extends StatelessWidget {
  const _Cabecalho();

  @override
  Widget build(BuildContext context) {
    return Column(
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
          'PiramidGame',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Text(
          'IFPR · Campus Paranaguá',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
        ),
      ],
    );
  }
}

class _SeparadorOu extends StatelessWidget {
  const _SeparadorOu();

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2);
    return Row(
      children: [
        Expanded(child: Divider(color: cor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('ou', style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(child: Divider(color: cor)),
      ],
    );
  }
}
