import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Identidade visual do app HallIf (item 2 da especificação: "arquivo
/// próprio de tema para definir a identidade visual do aplicativo").
///
/// Conceito: "mural de pátio escolar" / crachá de evento de campus —
/// uma paleta vibrante de "diploma e medalha" (roxo, dourado, coral),
/// tipografia com uma display face de peso (Fraunces) para títulos e
/// "Nível Lenda", e uma face utilitária (Inter) para o corpo do texto.
class AppTheme {
  AppTheme._();

  // Paleta nomeada -----------------------------------------------------
  static const tinta = Color(0xFF1A1423); // texto principal, quase preto arroxeado
  static const papel = Color(0xFFFBF6EC); // fundo claro, tom de papel
  static const papelEscuro = Color(0xFF121212); // fundo escuro (preto/cinza tradicional)
  static const roxoRecreio = Color(0xFF5B3E8C); // cor primária
  static const ouroLenda = Color(0xFFF2B705); // Nível Lenda, 1º lugar
  static const coralResenha = Color(0xFFF25C54); // ações/destaque secundário
  static const verdePrata = Color(0xFF7FA99B); // sucesso, 2º lugar

  /// Cores de destaque do pódio no ranking.
  static const corOuro = Color(0xFFF2B705);
  static const corPrata = Color(0xFFC9CCD1);
  static const corBronze = Color(0xFFCD7F32);

  /// Cor de faixa lateral por curso, usada nos cards de aluno — só um
  /// acento visual para diferenciar cursos rapidamente na listagem.
  static const Map<String, Color> corPorCurso = {
    'INFO': Color(0xFF5B3E8C),
    'MEC': Color(0xFFF25C54),
    'MAMB': Color(0xFF7FA99B),
    'PROD': Color(0xFFF2B705),
    'TADS': Color(0xFF3E7CB1),
    'TGA': Color(0xFFB15B3E),
  };

  // Tipografia -----------------------------------------------------------
  static TextTheme _buildTextTheme(TextTheme base, Color cor) {
    final display = GoogleFonts.fraunces(
      fontWeight: FontWeight.w700,
      color: cor,
    );
    final corpo = GoogleFonts.inter(color: cor);

    return base.copyWith(
      displayLarge: display.copyWith(fontSize: 52, letterSpacing: -0.5),
      displayMedium: display.copyWith(fontSize: 40, letterSpacing: -0.5),
      displaySmall: display.copyWith(fontSize: 32),
      headlineLarge: display.copyWith(fontSize: 28),
      headlineMedium: display.copyWith(fontSize: 24),
      headlineSmall: display.copyWith(fontSize: 20),
      titleLarge: display.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.inter(
        color: cor,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: GoogleFonts.inter(
        color: cor,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: corpo.copyWith(fontSize: 16),
      bodyMedium: corpo.copyWith(fontSize: 14),
      bodySmall: corpo.copyWith(fontSize: 12),
      labelLarge: corpo.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: roxoRecreio,
      onPrimary: papel,
      primaryContainer: Color(0xFFE6DAFA),
      onPrimaryContainer: roxoRecreio,
      secondary: ouroLenda,
      onSecondary: tinta,
      secondaryContainer: Color(0xFFFCEAB0),
      onSecondaryContainer: Color(0xFF6B4F00),
      tertiary: coralResenha,
      onTertiary: papel,
      surface: papel,
      onSurface: tinta,
      surfaceContainerHighest: Color(0xFFEFE6D8),
      error: coralResenha,
      onError: papel,
    );

    final base = ThemeData(useMaterial3: true, colorScheme: colorScheme);

    return base.copyWith(
      scaffoldBackgroundColor: papel,
      textTheme: _buildTextTheme(base.textTheme, tinta),
      appBarTheme: AppBarTheme(
        backgroundColor: papel,
        foregroundColor: tinta,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: GoogleFonts.fraunces(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: tinta,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: tinta.withValues(alpha: 0.08)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: tinta.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: roxoRecreio, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: roxoRecreio,
          foregroundColor: papel,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: coralResenha,
        foregroundColor: papel,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: roxoRecreio,
        thumbColor: ouroLenda,
        overlayColor: ouroLenda.withValues(alpha: 0.2),
      ),
      dividerColor: tinta.withValues(alpha: 0.08),
    );
  }

  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: Color(0xFFCBB6F0),
      onPrimary: Color(0xFF2A1F42),
      primaryContainer: Color(0xFF3D2C63),
      onPrimaryContainer: Color(0xFFE6DAFA),
      secondary: ouroLenda,
      onSecondary: Color(0xFF3D2D00),
      secondaryContainer: Color(0xFF53400A),
      onSecondaryContainer: Color(0xFFFCEAB0),
      tertiary: Color(0xFFF89490),
      onTertiary: Color(0xFF430E0C),
      surface: papelEscuro,
      onSurface: papel,
      surfaceContainerHighest: Color(0xFF262626),
      error: Color(0xFFF89490),
      onError: Color(0xFF430E0C),
    );

    final base = ThemeData(useMaterial3: true, colorScheme: colorScheme);

    return base.copyWith(
      scaffoldBackgroundColor: papelEscuro,
      textTheme: _buildTextTheme(base.textTheme, papel),
      appBarTheme: AppBarTheme(
        backgroundColor: papelEscuro,
        foregroundColor: papel,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: GoogleFonts.fraunces(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: papel,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1E1E1E),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: papel.withValues(alpha: 0.08)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: papel.withValues(alpha: 0.15)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: ouroLenda, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ouroLenda,
          foregroundColor: const Color(0xFF3D2D00),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: coralResenha,
        foregroundColor: papel,
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: ouroLenda,
        thumbColor: Color(0xFFCBB6F0),
        overlayColor: Color(0x33CBB6F0),
      ),
      dividerColor: papel.withValues(alpha: 0.1),
    );
  }
}
