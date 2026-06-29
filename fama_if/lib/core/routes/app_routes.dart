import 'package:go_router/go_router.dart';

import '../../presentation/views/about_view.dart';
import '../../presentation/views/aluno_form_view.dart';
import '../../presentation/views/aluno_detalhes_view.dart';
import '../../presentation/views/home_view.dart';
import '../../presentation/views/ranking_view.dart';
import '../../presentation/views/splash_view.dart';
import 'app_routes_constants.dart';


final goRouter = GoRouter(
  initialLocation: AppPaths.splash,
  routes: [
    GoRoute(
      path: AppPaths.splash,
      name: AppRouteNames.splash,
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      path: AppPaths.home,
      name: AppRouteNames.home,
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(
      path: AppPaths.cadastro,
      name: AppRouteNames.cadastro,
      builder: (context, state) {
        // Quando vier um id na query string (?id=...), a tela entra em
        // modo edição, carregando os dados do aluno existente.
        final id = state.uri.queryParameters['id'];
        return AlunoFormView(alunoId: id);
      },
    ),
    GoRoute(
      path: AppPaths.detalhes,
      name: AppRouteNames.detalhes,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AlunoDetalhesView(alunoId: id);
      },
    ),
    GoRoute(
      path: AppPaths.ranking,
      name: AppRouteNames.ranking,
      builder: (context, state) => const RankingView(),
    ),
    GoRoute(
      path: AppPaths.sobre,
      name: AppRouteNames.sobre,
      builder: (context, state) => const AboutView(),
    ),
  ],
);
