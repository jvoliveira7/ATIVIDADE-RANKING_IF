/// Caminhos (paths) de cada rota do app, usados pelo go_router.
class AppPaths {
  AppPaths._();

  static const splash = '/';

  // Rotas públicas: as únicas acessíveis sem sessão (item 6).
  static const login = '/login';
  static const cadastroUsuario = '/cadastro-usuario';

  /// Passo obrigatório logo após o primeiro acesso: cria a pessoa vinculada
  /// ao usuário, sem a qual não há como barrar autoavaliação (item 14.12).
  static const completarPerfil = '/completar-perfil';

  // Área autenticada
  static const pessoas = '/pessoas';
  static const pessoaForm = '/pessoas/cadastro';
  static const pessoaDetalhes = '/pessoas/:id';
  static const pessoaAvaliar = '/pessoas/:id/avaliar';
  static const rankingPessoal = '/ranking-pessoal';
  static const rankingGlobal = '/ranking-global';
  static const sobre = '/sobre';

  /// Tela para onde o usuário autenticado é levado por padrão (item 24).
  static const home = pessoas;
}

class AppRouteNames {
  AppRouteNames._();

  static const splash = 'splash';
  static const login = 'login';
  static const cadastroUsuario = 'cadastro_usuario';
  static const completarPerfil = 'completar_perfil';
  static const pessoas = 'pessoas';
  static const pessoaForm = 'pessoa_form';
  static const pessoaDetalhes = 'pessoa_detalhes';
  static const pessoaAvaliar = 'pessoa_avaliar';
  static const rankingPessoal = 'ranking_pessoal';
  static const rankingGlobal = 'ranking_global';
  static const sobre = 'sobre';
}
