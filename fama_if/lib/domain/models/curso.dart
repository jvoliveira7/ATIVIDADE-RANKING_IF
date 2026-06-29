/// Cursos disponíveis no IFPR - Campus Paranaguá.
/// Definido como enum (e não String livre) para forçar a seleção
/// a partir de uma lista pré-definida, conforme exigido na especificação (item 6.1).
enum Curso {
  info,
  mec,
  mamb,
  prod,
  tads,
  tga;

  /// Nome de exibição amigável, usado na UI (dropdowns, listagem, etc).
  String get displayName {
    switch (this) {
      case Curso.info:
        return 'INFO';
      case Curso.mec:
        return 'MEC';
      case Curso.mamb:
        return 'MAMB';
      case Curso.prod:
        return 'PROD';
      case Curso.tads:
        return 'TADS';
      case Curso.tga:
        return 'TGA';
    }
  }
}
