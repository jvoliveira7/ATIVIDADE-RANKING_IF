import 'package:go_router/go_router.dart';

import '../../presentation/controllers/auth_state_viewmodel.dart';
import '../../presentation/controllers/auth_viewmodel.dart';
import '../../presentation/views/about_view.dart';
import '../../presentation/views/avaliar_pessoa_view.dart';
import '../../presentation/views/cadastro_usuario_view.dart';
import '../../presentation/views/completar_perfil_view.dart';
import '../../presentation/views/login_view.dart';
import '../../presentation/views/pessoa_detalhes_view.dart';
import '../../presentation/views/pessoa_form_view.dart';
import '../../presentation/views/pessoas_view.dart';
import '../../presentation/views/ranking_global_view.dart';
import '../../presentation/views/ranking_pessoal_view.dart';
import '../../presentation/views/splash_view.dart';
import '../di/dependency_injection.dart';
import 'app_routes_constants.dart';
import 'auth_refresh_notifier.dart';

final _authViewModel = injector.get<AuthViewModel>();

/// Rotas do app com a trava de sessão centralizada no `redirect`.
///
/// Esta é a primeira das camadas de controle de sessão: nenhuma tela da área
/// autenticada é alcançável sem sessão válida, nem digitando a URL direto nem
/// por um `go` perdido no código (itens 6 e 23). As outras camadas ficam nos
/// use cases, nos services e nas Security Rules do Firestore.
final goRouter = GoRouter(
  initialLocation: AppPaths.splash,
  refreshListenable: AuthRefreshNotifier(_authViewModel.state),
  redirect: (context, state) {
    final sessao = _authViewModel.state;
    final destino = state.matchedLocation;

    // Enquanto o Firebase não termina de restaurar a sessão, todo mundo
    // espera na splash — decidir agora jogaria quem está logado no login.
    if (sessao.status.value == AuthStatus.desconhecido) {
      return destino == AppPaths.splash ? null : AppPaths.splash;
    }

    final publica =
        destino == AppPaths.login || destino == AppPaths.cadastroUsuario;

    if (!sessao.autenticado) return publica ? null : AppPaths.login;

    // Logado, mas ainda sem pessoa vinculada.
    if (sessao.precisaCompletarPerfil.value) {
      return destino == AppPaths.completarPerfil
          ? null
          : AppPaths.completarPerfil;
    }

    // Logado e com perfil completo não fica preso em splash, login ou no
    // passo de completar perfil.
    if (publica ||
        destino == AppPaths.splash ||
        destino == AppPaths.completarPerfil) {
      return AppPaths.home;
    }

    return null;
  },
  routes: [
    GoRoute(
      path: AppPaths.splash,
      name: AppRouteNames.splash,
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      path: AppPaths.login,
      name: AppRouteNames.login,
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: AppPaths.cadastroUsuario,
      name: AppRouteNames.cadastroUsuario,
      builder: (context, state) => const CadastroUsuarioView(),
    ),
    GoRoute(
      path: AppPaths.completarPerfil,
      name: AppRouteNames.completarPerfil,
      builder: (context, state) => const CompletarPerfilView(),
    ),
    GoRoute(
      path: AppPaths.pessoas,
      name: AppRouteNames.pessoas,
      builder: (context, state) => const PessoasView(),
    ),
    GoRoute(
      path: AppPaths.pessoaForm,
      name: AppRouteNames.pessoaForm,
      builder: (context, state) {
        // Com `?id=`, a tela entra em modo de edição (item 14.8).
        return PessoaFormView(pessoaId: state.uri.queryParameters['id']);
      },
    ),
    GoRoute(
      path: AppPaths.pessoaDetalhes,
      name: AppRouteNames.pessoaDetalhes,
      builder: (context, state) =>
          PessoaDetalhesView(pessoaId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: AppPaths.pessoaAvaliar,
      name: AppRouteNames.pessoaAvaliar,
      builder: (context, state) =>
          AvaliarPessoaView(pessoaId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: AppPaths.rankingPessoal,
      name: AppRouteNames.rankingPessoal,
      builder: (context, state) => const RankingPessoalView(),
    ),
    GoRoute(
      path: AppPaths.rankingGlobal,
      name: AppRouteNames.rankingGlobal,
      builder: (context, state) => const RankingGlobalView(),
    ),
    GoRoute(
      path: AppPaths.sobre,
      name: AppRouteNames.sobre,
      builder: (context, state) => const AboutView(),
    ),
  ],
);
