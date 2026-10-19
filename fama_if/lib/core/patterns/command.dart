import 'package:signals_flutter/signals_flutter.dart';

import 'result.dart';

// Interface base para comandos
abstract interface class ICommand<TOk, TError> {
  Future<Result<TOk, TError>> execute();
}

// Comando abstrato com estado reativo
abstract base class Command<TOk, TError> implements ICommand<TOk, TError> {
  final _running = signal(false);
  final _result = signal<Result<TOk, TError>?>(null);

  // Execução em andamento, reaproveitada se o comando for chamado de novo
  // antes de terminar (ex.: toque duplo no botão).
  Future<Result<TOk, TError>>? _pending;

  // Getters para os sinais reativos
  ReadonlySignal<bool> get isExecuting => _running.readonly();
  ReadonlySignal<Result<TOk, TError>?> get result => _result.readonly();

  // Computed signals
  late final hasResult = computed(() => _result.value != null);
  late final hasError = computed(() => _result.value?.isFailure ?? false);
  late final isSuccess = computed(() => _result.value?.isSuccess ?? false);

  // Executa o comando. Se já estiver rodando, devolve a mesma execução em
  // andamento em vez de iniciar outra.
  Future<Result<TOk, TError>> call() {
    return _pending ??= _run();
  }

  Future<Result<TOk, TError>> _run() async {
    _running.value = true; // indica que está rodando
    _result.value = null; // limpa resultado anterior
    try {
      final resultado = await execute(); // executa a ação
      _result.value = resultado;
      return resultado;
    } finally {
      _running.value = false; // indica que terminou, mesmo se execute() lançar
      _pending = null;
    }
  }

  void clear() {
    _result.value = null;
  }

  void reset() {
    _running.value = false;
    clear();
  }
}

// Comando parametrizado
abstract base class ParameterizedCommand<TOk, TError, P>
    extends Command<TOk, TError> {
  P? parameter;

  Future<Result<TOk, TError>> executeWith(P parameter) {
    this.parameter = parameter;
    return call();
  }

  @override
  Future<Result<TOk, TError>> execute();
}