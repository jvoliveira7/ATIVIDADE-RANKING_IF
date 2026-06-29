/// Caminhos (paths) de cada rota do app, usados pelo go_router
class AppPaths {
  AppPaths._();

  static const splash = '/';
  static const home = '/home';
  static const cadastro = '/cadastro';
  static const detalhes = '/detalhes/:id';
  static const edicao = '/edicao/:id';
  static const ranking = '/ranking';
  static const sobre = '/sobre';
}


class AppRouteNames {
  AppRouteNames._();

  static const splash = 'splash';
  static const home = 'home';
  static const cadastro = 'cadastro';
  static const detalhes = 'detalhes';
  static const edicao = 'edicao';
  static const ranking = 'ranking';
  static const sobre = 'sobre';
}
