import 'package:flutter/material.dart';

/// الهوية البصرية: ليلٌ عميق مع ذهبٍ زاهٍ ولمسة زمردية — تصميم فخم وعصري.
class AppTheme {
  static const Color nightTop = Color(0xFF0E1230);
  static const Color nightBottom = Color(0xFF1B1035);
  static const Color card = Color(0xFF221A44);
  static const Color cardSoft = Color(0xFF2B2153);
  static const Color gold = Color(0xFFE8B84B);
  static const Color goldDeep = Color(0xFFC99A2E);
  static const Color mint = Color(0xFF3DDC97);
  static const Color rose = Color(0xFFFF6B81);
  static const Color ink = Color(0xFFF5F1E8);
  static const Color inkDim = Color(0xB3F5F1E8);

  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [nightTop, nightBottom],
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF3CE7C), gold, goldDeep],
  );

  static ThemeData theme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: null,
      colorScheme: const ColorScheme.dark(
        primary: gold,
        secondary: mint,
        surface: card,
        error: rose,
      ),
      cardTheme: CardTheme(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: ink,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
        titleLarge: TextStyle(color: ink, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(color: ink, height: 1.7),
        bodyMedium: TextStyle(color: inkDim, height: 1.7),
      ),
    );
  }
}

/// بطاقة زجاجية موحّدة الشكل.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (color ?? AppTheme.card).withOpacity(0.96),
            AppTheme.cardSoft.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.gold.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}
