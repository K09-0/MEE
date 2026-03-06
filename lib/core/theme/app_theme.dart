import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Cyberpunk/Neon Theme for MEE App
/// 
/// Темная тема по умолчанию с неоновыми акцентами (фиолетовый/зеленый)
/// Material 3 Design System с кастомными модификациями
class AppTheme {
  AppTheme._(); // Private constructor
  
  // ==================== COLOR PALETTE ====================
  
  // Primary Colors - Neon Purple
  static const Color primaryColor = Color(0xFFB829F7);
  static const Color primaryLight = Color(0xFFE066FF);
  static const Color primaryDark = Color(0xFF7B1FA2);
  static const Color primaryContainer = Color(0xFF2D1B4E);
  
  // Secondary Colors - Neon Green
  static const Color secondaryColor = Color(0xFF00F5A0);
  static const Color secondaryLight = Color(0xFF5FFFBF);
  static const Color secondaryDark = Color(0xFF00C853);
  static const Color secondaryContainer = Color(0xFF1B3D2F);
  
  // Accent Colors - Neon Blue & Pink
  static const Color accentBlue = Color(0xFF00D4FF);
  static const Color accentPink = Color(0xFFFF006E);
  static const Color accentOrange = Color(0xFFFF9F1C);
  static const Color accentYellow = Color(0xFFFFEA00);
  
  // Background Colors - Deep Dark
  static const Color backgroundDark = Color(0xFF0A0A0F);
  static const Color backgroundDarker = Color(0xFF050508);
  static const Color surfaceDark = Color(0xFF12121A);
  static const Color surfaceDarker = Color(0xFF0D0D14);
  static const Color cardDark = Color(0xFF1A1A24);
  
  // Light Background Colors (for light theme if needed)
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB3B3B3);
  static const Color textTertiaryDark = Color(0xFF666666);
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF666666);
  
  // Status Colors
  static const Color success = Color(0xFF00F5A0);
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFF9F1C);
  static const Color info = Color(0xFF00D4FF);
  
  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFFB829F7),
    Color(0xFF7B1FA2),
  ];
  
  static const List<Color> secondaryGradient = [
    Color(0xFF00F5A0),
    Color(0xFF00C853),
  ];
  
  static const List<Color> accentGradient = [
    Color(0xFF00D4FF),
    Color(0xFFB829F7),
  ];
  
  static const List<Color> neonGlow = [
    Color(0xFFB829F7),
    Color(0xFF00F5A0),
    Color(0xFF00D4FF),
  ];
  
  // ==================== DARK THEME ====================
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: primaryContainer,
        onPrimaryContainer: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.black,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: Colors.white,
        tertiary: accentBlue,
        onTertiary: Colors.black,
        surface: surfaceDark,
        onSurface: textPrimaryDark,
        surfaceContainerHighest: cardDark,
        onSurfaceVariant: textSecondaryDark,
        background: backgroundDark,
        onBackground: textPrimaryDark,
        error: error,
        onError: Colors.white,
        errorContainer: Color(0xFF3D1F1F),
        onErrorContainer: error,
        outline: Color(0xFF3D3D4D),
        outlineVariant: Color(0xFF2A2A3A),
        shadow: Colors.black,
        scrim: Colors.black54,
        inverseSurface: surfaceLight,
        onInverseSurface: textPrimaryLight,
        inversePrimary: primaryLight,
        surfaceTint: primaryColor,
      ),
      
      // Typography
      textTheme: _buildTextTheme(Brightness.dark),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: backgroundDark.withOpacity(0.8),
        foregroundColor: textPrimaryDark,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        elevation: 0,
        color: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _buildElevatedButtonStyle(),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _buildOutlinedButtonStyle(),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: _buildTextButtonStyle(),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: _buildInputDecorationTheme(),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryColor,
        unselectedItemColor: textTertiaryDark,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: surfaceDarker,
        selectedColor: primaryContainer,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          color: textPrimaryDark,
        ),
        secondaryLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          color: primaryColor,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: const Color(0xFF2A2A3A),
        thickness: 1,
        space: 1,
      ),
      
      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
      ),
      
      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardDark,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: textPrimaryDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: Color(0xFF2A2A3A),
        circularTrackColor: Color(0xFF2A2A3A),
      ),
      
      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: const Color(0xFF2A2A3A),
        thumbColor: primaryColor,
        overlayColor: primaryColor.withOpacity(0.2),
        trackHeight: 4,
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return textTertiaryDark;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryContainer;
          }
          return const Color(0xFF2A2A3A);
        }),
      ),
      
      // Tab Bar Theme
      tabBarTheme: TabBarTheme(
        labelColor: primaryColor,
        unselectedLabelColor: textSecondaryDark,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        indicatorColor: primaryColor,
        indicatorSize: TabBarIndicatorSize.label,
      ),
      
      // Scrolled Under Elevation
      scaffoldBackgroundColor: backgroundDark,
      
      // Visual Density
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
  
  // ==================== LIGHT THEME (Optional) ====================
  
  static ThemeData get lightTheme {
    // For now, light theme is similar to dark but with light backgrounds
    // Can be expanded based on requirements
    return darkTheme.copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
    );
  }
  
  // ==================== TEXT THEME ====================
  
  static TextTheme _buildTextTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primaryText = isDark ? textPrimaryDark : textPrimaryLight;
    final secondaryText = isDark ? textSecondaryDark : textSecondaryLight;
    
    return TextTheme(
      // Display
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: primaryText,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: primaryText,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.spaceGrotesk(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      
      // Headline
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      headlineSmall: GoogleFonts.spaceGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      
      // Title
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryText,
      ),
      
      // Body
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primaryText,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primaryText,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryText,
      ),
      
      // Label
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryText,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondaryText,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: secondaryText,
        letterSpacing: 0.5,
      ),
    );
  }
  
  // ==================== BUTTON STYLES ====================
  
  static ButtonStyle _buildElevatedButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      minimumSize: const Size(double.infinity, 56),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      textStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
  
  static ButtonStyle _buildOutlinedButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: primaryColor,
      side: const BorderSide(color: primaryColor, width: 2),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      minimumSize: const Size(double.infinity, 56),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      textStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
  
  static ButtonStyle _buildTextButtonStyle() {
    return TextButton.styleFrom(
      foregroundColor: primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
  
  // ==================== INPUT DECORATION ====================
  
  static InputDecorationTheme _buildInputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: surfaceDarker,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      hintStyle: GoogleFonts.inter(
        fontSize: 16,
        color: textTertiaryDark,
      ),
      labelStyle: GoogleFonts.inter(
        fontSize: 16,
        color: textSecondaryDark,
      ),
      errorStyle: GoogleFonts.inter(
        fontSize: 12,
        color: error,
      ),
      prefixIconColor: textTertiaryDark,
      suffixIconColor: textTertiaryDark,
    );
  }
  
  // ==================== GRADIENT WIDGETS ====================
  
  static BoxDecoration get primaryGradientDecoration {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: primaryGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
    );
  }
  
  static BoxDecoration get neonGlowDecoration {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: neonGlow,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ],
    );
  }
  
  // ==================== UTILITY METHODS ====================
  
  /// Get neon glow shadow
  static List<BoxShadow> getNeonShadow({Color color = primaryColor}) {
    return [
      BoxShadow(
        color: color.withOpacity(0.4),
        blurRadius: 15,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: color.withOpacity(0.2),
        blurRadius: 30,
        spreadRadius: 5,
      ),
    ];
  }
  
  /// Get glass morphism decoration
  static BoxDecoration getGlassDecoration({double opacity = 0.1}) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
        width: 1,
      ),
    );
  }
}

/// Extension for easy theme access
extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
