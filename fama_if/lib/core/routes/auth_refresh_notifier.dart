import 'package:flutter/foundation.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../presentation/controllers/auth_state_viewmodel.dart';

/// Ponte entre os signals da sessão e o `refreshListenable` do go_router.
///
/// O go_router só reavalia o `redirect` quando a navegação muda ou quando um
/// [Listenable] avisa. Sem esta ponte, deslogar não tiraria o usuário da tela
/// em que ele está: a trava só valeria na próxima navegação.
class AuthRefreshNotifier extends ChangeNotifier {
  late final void Function() _cancelar;

  AuthRefreshNotifier(AuthState state) {
    _cancelar = effect(() {
      // Lê os dois signals para que o effect passe a depender de ambos.
      state.status.value;
      state.precisaCompletarPerfil.value;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _cancelar();
    super.dispose();
  }
}
