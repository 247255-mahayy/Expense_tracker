import 'package:flutter/material.dart';

class AppColors {
  static const Color obsidianBackground = Color(0xFF0D0A12);
  static const Color geometricCard = Color(0xFF161120);
  static const Color glassSurface = Color(0xFF1F182E);

  static const Color velvetPurple = Color(0xFF3F1B63);
  static const Color deepRoyalViolet = Color(0xFF5E318D);
  static const Color activeGlow = Color(0xFF7B42BC);
  static const Color mutedLavender = Color(0xFF8E72A7);
  static const Color softLilac = Color(0xFFBFA2DB);
  static const Color pastelLavender = Color(0xFFD3C3E5);
  static const Color roseQuartz = Color(0xFFA59AB2);

  static const Color incomeGreen = Color(0xFF4E9F82);
  static const Color expenseRed = Color(0xFFB0567B);
  static const Color warningOrange = Color(0xFFE58F65);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color subtleBorder = Color(0xFF2C213D);

  static const Color dividerColor = Color(0xFF261D36);
  static const Color snackBarBackground = Color(0xFF211930);

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF231836), Color(0xFF140F21)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryButtonGradient = LinearGradient(
    colors: [Color(0xFF7B42BC), Color(0xFF4A2578)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient graphGradient = LinearGradient(
    colors: [Color(0x807B42BC), Color(0x000D0A12)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static Color getTransactionColor(bool isIncome) {
    return isIncome ? incomeGreen : expenseRed;
  }

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'dining':
        return const Color(0xFF9A79BA);
      case 'shopping':
        return const Color(0xFFD4AF37);
      case 'transport':
      case 'travel':
        return const Color(0xFF4E9F82);
      case 'bills':
      case 'utilities':
        return const Color(0xFFB0567B);
      case 'entertainment':
        return const Color(0xFF7B42BC);
      default:
        return softLilac;
    }
  }

  static BoxDecoration getGlassCardDecoration({
    double borderRadius = 22.0,
    Color borderColor = subtleBorder,
  }) {
    return BoxDecoration(
      color: geometricCard,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor, width: 1.2),
      boxShadow: [
        BoxShadow(
          color: activeGlow.withValues(alpha: 0.2),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration getGradientCardDecoration({
    double borderRadius = 22.0,
  }) {
    return BoxDecoration(
      gradient: cardGradient,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: subtleBorder, width: 1.2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.obsidianBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.softLilac,
        secondary: AppColors.goldAccent,
        surface: AppColors.geometricCard,
        onSurface: AppColors.pastelLavender,
        primaryContainer: AppColors.deepRoyalViolet,
        error: AppColors.expenseRed,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.softLilac,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
        ),
        headlineMedium: TextStyle(
          color: AppColors.softLilac,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        headlineSmall: TextStyle(
          color: AppColors.pastelLavender,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          color: AppColors.softLilac,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: AppColors.pastelLavender,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: AppColors.pastelLavender),
        bodyMedium: TextStyle(color: AppColors.roseQuartz),
        labelLarge: TextStyle(
          color: AppColors.softLilac,
          fontWeight: FontWeight.bold,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.geometricCard,
        indicatorColor: AppColors.deepRoyalViolet,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(color: AppColors.pastelLavender, fontSize: 12),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.softLilac);
          }
          return const IconThemeData(color: AppColors.roseQuartz);
        }),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.obsidianBackground,
        foregroundColor: AppColors.pastelLavender,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.geometricCard,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.subtleBorder, width: 1.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.geometricCard,
        labelStyle: const TextStyle(color: AppColors.mutedLavender),
        hintStyle: const TextStyle(color: AppColors.roseQuartz),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.subtleBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.softLilac, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.expenseRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.expenseRed, width: 1.8),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.activeGlow,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepRoyalViolet,
          foregroundColor: AppColors.pastelLavender,
          elevation: 6,
          shadowColor: AppColors.activeGlow.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.softLilac,
          side: const BorderSide(color: AppColors.activeGlow, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.softLilac,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.geometricCard,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.subtleBorder, width: 1.2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.snackBarBackground,
        contentTextStyle: const TextStyle(color: AppColors.pastelLavender),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerColor,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.glassSurface,
        disabledColor: AppColors.geometricCard,
        selectedColor: AppColors.deepRoyalViolet,
        secondarySelectedColor: AppColors.activeGlow,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: const TextStyle(color: AppColors.pastelLavender),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.subtleBorder),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.geometricCard,
        modalBackgroundColor: AppColors.geometricCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }
}