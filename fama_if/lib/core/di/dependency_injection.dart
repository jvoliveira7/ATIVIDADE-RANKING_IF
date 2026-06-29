import 'package:auto_injector/auto_injector.dart';

import '../../data/repositories/aluno_repository_impl.dart';
import '../../data/repositories/aluno_repository_interface.dart';
import '../../data/services/aluno_local_storage_interface.dart';
import '../../data/services/aluno_shared_preferences_impl.dart';
import '../../domain/facades/aluno_facade_usecases_impl.dart';
import '../../domain/facades/aluno_facade_usecases_interface.dart';
import '../../domain/usecases/aluno_usecases_impl.dart';
import '../../domain/usecases/aluno_usecases_interfaces.dart';
import '../../presentation/controllers/aluno_viewmodel.dart';
import '../theme/theme_controller.dart';

/// Container de injeção de dependências do app, usando o pacote
/// `auto_injector` (igual ao usado pelo professor no projeto de
/// referência).
///
/// Cada `injector.add(...)` registra uma "receita" de como construir um
/// tipo: o auto_injector resolve automaticamente as dependências de cada
/// construtor (por isso a ordem de registro abaixo segue a mesma ordem
/// das camadas: service → repository → use cases → facade → viewmodel).
final injector = AutoInjector();

void setupDependencyInjection() {
  // Core
  injector.addSingleton(ThemeController.new);

  // Services (camada de acesso ao SharedPreferences)
  injector.addSingleton<IAlunoLocalStorage>(AlunoSharedPreferencesService.new);

  // Repositories
  injector.addSingleton<IAlunoRepository>(AlunoRepositoryImpl.new);

  // Use cases
  injector.addSingleton<ICadastrarAlunoUseCase>(CadastrarAlunoUseCase.new);
  injector.addSingleton<IBuscarTodosAlunosUseCase>(BuscarTodosAlunosUseCase.new);
  injector.addSingleton<IBuscarAlunoPorIdUseCase>(BuscarAlunoPorIdUseCase.new);
  injector.addSingleton<IAlterarAlunoUseCase>(AlterarAlunoUseCase.new);
  injector.addSingleton<IRemoverAlunoUseCase>(RemoverAlunoUseCase.new);
  injector.addSingleton<ICalcularRankingUseCase>(CalcularRankingUseCase.new);

  // Facade
  injector.addSingleton<IAlunoFacadeUseCases>(AlunoFacadeUseCasesImpl.new);

  // ViewModel (singleton: o estado da lista de alunos é compartilhado
  // entre todas as telas que o consomem, ex: Home e Ranking)
  injector.addSingleton(AlunoViewModel.new);

  injector.commit();
}
