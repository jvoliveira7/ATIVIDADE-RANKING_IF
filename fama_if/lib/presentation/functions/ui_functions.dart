import '../../core/failure/failure.dart';
import '../../core/validators/base_validator.dart';
import '../../core/validators/text_field_validator.dart';

/// Adapta a cadeia de validadores ([BaseValidator]) para o formato
/// esperado pelo parâmetro `validator` de um `TextFormField` do Flutter:
/// uma função que recebe o valor digitado e retorna `null` (válido) ou
/// uma `String` com a mensagem de erro (inválido).
///
/// Os validadores lançam exceções [Failure] quando a validação falha;
/// aqui essas exceções são capturadas e convertidas na mensagem que o
/// campo de formulário deve exibir.
String? validateField(String? value, List<BaseValidator> validators) {
  try {
    TextFieldValidator(validators: validators).validations(value);
    return null;
  } on Failure catch (e) {
    return e.msg;
  }
}
