import 'package:auto_injector/auto_injector.dart';
import 'package:uuid/uuid.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/avaliacao_repository_impl.dart';
import '../../data/repositories/i_auth_repository.dart';
import '../../data/repositories/i_avaliacao_repository.dart';
import '../../data/repositories/i_pessoa_repository.dart';
import '../../data/repositories/i_preference_repository.dart';
import '../../data/repositories/i_ranking_repository.dart';
import '../../data/repositories/i_usuario_repository.dart';
import '../../data/repositories/pessoa_repository_impl.dart';
import '../../data/repositories/preference_repository_impl.dart';
import '../../data/repositories/ranking_repository_impl.dart';
import '../../data/repositories/usuario_repository_impl.dart';
import '../../data/services/firebase_auth_service.dart';
import '../../data/services/firestore_avaliacao_service.dart';
import '../../data/services/firestore_pessoa_service.dart';
import '../../data/services/firestore_usuario_service.dart';
import '../../data/services/i_auth_service.dart';
import '../../data/services/i_avaliacao_service.dart';
import '../../data/services/i_local_storage_service.dart';
import '../../data/services/i_pessoa_service.dart';
import '../../data/services/i_usuario_service.dart';
import '../../data/services/shared_pref_local_storage_service.dart';
import '../../domain/facades/auth_facade_impl.dart';
import '../../domain/facades/avaliacao_facade_impl.dart';
import '../../domain/facades/i_auth_facade.dart';
import '../../domain/facades/i_avaliacao_facade.dart';
import '../../domain/facades/i_pessoa_facade.dart';
import '../../domain/facades/i_ranking_facade.dart';
import '../../domain/facades/pessoa_facade_impl.dart';
import '../../domain/facades/ranking_facade_impl.dart';
import '../../domain/usecases/auth_usecases_impl.dart';
import '../../domain/usecases/avaliacao_usecases_impl.dart';
import '../../domain/usecases/i_auth_usecases.dart';
import '../../domain/usecases/i_avaliacao_usecases.dart';
import '../../domain/usecases/i_pessoa_usecases.dart';
import '../../domain/usecases/i_preference_usecases.dart';
import '../../domain/usecases/i_ranking_usecases.dart';
import '../../domain/usecases/pessoa_usecases_impl.dart';
import '../../domain/usecases/preference_usecases_impl.dart';
import '../../domain/usecases/ranking_usecases_impl.dart';
import '../../presentation/controllers/auth_viewmodel.dart';
import '../../presentation/controllers/avaliacao_viewmodel.dart';
import '../../presentation/controllers/pessoa_viewmodel.dart';
import '../../presentation/controllers/ranking_viewmodel.dart';
import '../theme/theme_controller.dart';

/// Container de injeção de dependências do app.
///
/// O registro segue a ordem das camadas exigida pelo item 4:
/// services → repositories → use cases → facades → viewmodels.
final injector = AutoInjector();

void setupDependencyInjection() {
  _registrarServices();
  _registrarRepositories();
  _registrarUseCases();
  _registrarFacades();
  _registrarViewModels();

  injector.commit();
}

/// Camada mais externa: quem fala com Firebase Auth, Firestore e
/// SharedPreferences (item 4.1).
///
/// As implementações são criadas por closure em vez de tear-off porque seus
/// construtores recebem dependências opcionais (usadas só nos testes, para
/// injetar dublês); deixadas em branco, elas assumem as instâncias reais.
void _registrarServices() {
  injector.addSingleton<IAuthService>(() => FirebaseAuthService());
  injector.addSingleton<IPessoaService>(() => FirestorePessoaService());
  injector.addSingleton<IAvaliacaoService>(() => FirestoreAvaliacaoService());
  injector.addSingleton<IUsuarioService>(() => FirestoreUsuarioService());
  injector.addSingleton<ILocalStorageService>(
    () => SharedPrefLocalStorageService(),
  );
}

/// Item 4.2.
void _registrarRepositories() {
  injector.addSingleton<IAuthRepository>(AuthRepositoryImpl.new);
  injector.addSingleton<IPessoaRepository>(PessoaRepositoryImpl.new);
  injector.addSingleton<IAvaliacaoRepository>(AvaliacaoRepositoryImpl.new);
  injector.addSingleton<IUsuarioRepository>(UsuarioRepositoryImpl.new);
  injector.addSingleton<IRankingRepository>(RankingRepositoryImpl.new);
  injector.addSingleton<IPreferenceRepository>(PreferenceRepositoryImpl.new);
}

/// Item 4.3.
void _registrarUseCases() {
  injector.addSingleton<Uuid>(Uuid.new);

  // Autenticação e sessão
  injector.addSingleton<ICadastrarUsuarioUseCase>(CadastrarUsuarioUseCase.new);
  injector.addSingleton<IEntrarComEmailUseCase>(EntrarComEmailUseCase.new);
  injector.addSingleton<IEntrarComGoogleUseCase>(EntrarComGoogleUseCase.new);
  injector.addSingleton<IVerificarUsuarioAutenticadoUseCase>(
    VerificarUsuarioAutenticadoUseCase.new,
  );
  injector.addSingleton<ISairUseCase>(SairUseCase.new);
  injector.addSingleton<ICompletarPerfilUseCase>(
    () => CompletarPerfilUseCase(
      authRepository: injector.get<IAuthRepository>(),
      usuarioRepository: injector.get<IUsuarioRepository>(),
      pessoaRepository: injector.get<IPessoaRepository>(),
      uuid: injector.get<Uuid>(),
    ),
  );

  // Pessoas
  injector.addSingleton<ICadastrarPessoaUseCase>(
    () => CadastrarPessoaUseCase(
      repository: injector.get<IPessoaRepository>(),
      authRepository: injector.get<IAuthRepository>(),
      uuid: injector.get<Uuid>(),
    ),
  );
  injector.addSingleton<IAlterarPessoaUseCase>(AlterarPessoaUseCase.new);
  injector.addSingleton<IRemoverPessoaUseCase>(RemoverPessoaUseCase.new);
  injector.addSingleton<IBuscarTodasPessoasUseCase>(
    BuscarTodasPessoasUseCase.new,
  );
  injector.addSingleton<IBuscarPessoaPorIdUseCase>(
    BuscarPessoaPorIdUseCase.new,
  );

  // Avaliações
  injector.addSingleton<IRegistrarAvaliacaoUseCase>(
    RegistrarAvaliacaoUseCase.new,
  );
  injector.addSingleton<IAlterarAvaliacaoUseCase>(AlterarAvaliacaoUseCase.new);
  injector.addSingleton<IConsultarAvaliacaoUseCase>(
    ConsultarAvaliacaoUseCase.new,
  );
  injector.addSingleton<IBuscarAvaliacoesDoUsuarioUseCase>(
    BuscarAvaliacoesDoUsuarioUseCase.new,
  );
  injector.addSingleton<IVerificarAutoavaliacaoUseCase>(
    VerificarAutoavaliacaoUseCase.new,
  );

  // Rankings
  injector.addSingleton<ICalcularRankingPessoalUseCase>(
    CalcularRankingPessoalUseCase.new,
  );
  injector.addSingleton<ICalcularRankingGlobalUseCase>(
    CalcularRankingGlobalUseCase.new,
  );

  // Preferências
  injector.addSingleton<IAlterarTemaUseCase>(AlterarTemaUseCase.new);
  injector.addSingleton<ICarregarTemaUseCase>(CarregarTemaUseCase.new);
}

/// Item 4.4.
void _registrarFacades() {
  injector.addSingleton<IAuthFacade>(AuthFacadeImpl.new);
  injector.addSingleton<IPessoaFacade>(PessoaFacadeImpl.new);
  injector.addSingleton<IAvaliacaoFacade>(AvaliacaoFacadeImpl.new);
  injector.addSingleton<IRankingFacade>(RankingFacadeImpl.new);
}

/// Item 4.5.
void _registrarViewModels() {
  injector.addSingleton<ThemeController>(ThemeController.new);
  injector.addSingleton<AuthViewModel>(AuthViewModel.new);
  injector.addSingleton<PessoaViewModel>(PessoaViewModel.new);
  injector.addSingleton<AvaliacaoViewModel>(AvaliacaoViewModel.new);
  injector.addSingleton<RankingViewModel>(RankingViewModel.new);
}
