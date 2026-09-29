
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _seed = Color(0xFF5B5FEF);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    );
    return _themeFrom(scheme);
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    );
    return _themeFrom(scheme);
  }

  static ThemeData _themeFrom(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardColor: scheme.surfaceContainerHighest,
      dividerColor: scheme.outlineVariant,
    );
  }
}
abstract final class StatusColors {
  static const newLead = Color(0xFF6366F1);
  static const contacted = Color(0xFF0EA5E9);
  static const qualified = Color(0xFF10B981);
  static const won = Color(0xFF8B5CF6);
  static const lost = Color(0xFFEF4444);
}

abstract final class PriorityColors {
  static const high = Color(0xFFEF4444);
  static const medium = Color(0xFFF59E0B);
  static const low = Color(0xFF10B981);
}