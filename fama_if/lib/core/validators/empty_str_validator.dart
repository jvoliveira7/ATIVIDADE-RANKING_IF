import '../failure/failure.dart';
import '../messages/app_messages.dart';
import 'base_validator.dart';

///valida que um campo de texto não está vazio ou nulo
final class EmptyStrValidator extends BaseValidator<String?> {
  @override
  bool validate(String? validation) {
    return switch (validation) {
      null => throw InputFailure(AppMessages.error.nullStringError),
      String v when v.trim().isEmpty =>
        throw InputFailure(AppMessages.error.nullStringError),
      _ => nextValidator?.validate(validation) ?? true,
    };
  }
}
