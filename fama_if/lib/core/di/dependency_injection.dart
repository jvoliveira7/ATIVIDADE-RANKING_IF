import 'package:auto_injector/auto_injector.dart';

import '../../data/repositories/aluno_repository_impl.dart';
import '../../data/repositories/aluno_repository_interface.dart';
import '../../data/services/aluno_local_storage_interface.dart';
import '../../data/services/aluno_sqlite_service_impl.dart'; 
import '../../domain/facades/aluno_facade_usecases_impl.dart';
import '../../domain/facades/aluno_facade_usecases_interface.dart';
import '../../domain/usecases/aluno_usecases_impl.dart';
import '../../domain/usecases/aluno_usecases_interfaces.dart';
import '../../presentation/controllers/aluno_viewmodel.dart';
import '../theme/theme_controller.dart';

/// Container de injeção de dependências do app.
///
/// A ÚNICA mudança em relação à versão com SharedPreferences está na
/// linha marcada abaixo: trocamos [AlunoSharedPreferencesService] por
/// [AlunoSqliteService]. Todo o resto do app (Repository, Use Cases,
/// Facade, ViewModel, UI) permanece idêntico — é exatamente o
/// benefício da Clean Architecture e da inversão de dependência.
final injector = AutoInjector();

void setupDependencyInjection() {
  // Core
  injector.addSingleton(ThemeController.new);

  // ↓ ÚNICA LINHA QUE MUDOU em relação à versão com SharedPreferences
  injector.addSingleton<IAlunoLocalStorage>(AlunoSqliteService.new);

  // Repositories — sem alteração
  injector.addSingleton<IAlunoRepository>(AlunoRepositoryImpl.new);

  // Use cases — sem alteração
  injector.addSingleton<ICadastrarAlunoUseCase>(CadastrarAlunoUseCase.new);
  injector.addSingleton<IBuscarTodosAlunosUseCase>(BuscarTodosAlunosUseCase.new);
  injector.addSingleton<IBuscarAlunoPorIdUseCase>(BuscarAlunoPorIdUseCase.new);
  injector.addSingleton<IAlterarAlunoUseCase>(AlterarAlunoUseCase.new);
  injector.addSingleton<IRemoverAlunoUseCase>(RemoverAlunoUseCase.new);
  injector.addSingleton<ICalcularRankingUseCase>(CalcularRankingUseCase.new);

  // Facade — sem alteração
  injector.addSingleton<IAlunoFacadeUseCases>(AlunoFacadeUseCasesImpl.new);

  // ViewModel — sem alteração
  injector.addSingleton(AlunoViewModel.new);

  injector.commit();
}
