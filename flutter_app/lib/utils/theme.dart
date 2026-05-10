// lib/utils/theme.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppTheme {
  static const Color bg       = Color(0xFF080B11);
  static const Color surface  = Color(0xFF0F1520);
  static const Color surface2 = Color(0xFF141B28);
  static const Color border   = Color(0xFF1C2535);
  static const Color accent   = Color(0xFFF97316);
  static const Color accent2  = Color(0xFFFB923C);
  static const Color textPrim = Color(0xFFE2E8F0);
  static const Color textSec  = Color(0xFF94A3B8);
  static const Color muted    = Color(0xFF4B5563);
  static const Color success  = Color(0xFF10B981);
  static const Color danger   = Color(0xFFEF4444);
  static const Color warning  = Color(0xFFF59E0B);
  static const Color info     = Color(0xFF3B82F6);

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      primary: accent,
      secondary: accent2,
      surface: surface,
      error: danger,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: textPrim,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: textPrim),
    ),
    // ✅ FIXED: CardTheme -> CardThemeData
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
      labelStyle: const TextStyle(color: textSec),
      hintStyle: const TextStyle(color: muted),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrim),
      bodyMedium: TextStyle(color: textSec),
      titleLarge: TextStyle(color: textPrim, fontWeight: FontWeight.w700),
    ),
    dividerColor: border,
    useMaterial3: true,
  );
}

String formatRupiah(dynamic angka) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return formatter.format(double.tryParse(angka.toString()) ?? 0);
}

String formatTanggal(String tanggal) {
  try {
    final dt = DateTime.parse(tanggal);
    return DateFormat('dd MMM yyyy', 'id_ID').format(dt);
  } catch (_) {
    return tanggal;
  }
}