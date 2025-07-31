import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminLteColors {
  static const primary = Color(0xFF007bff);
  static const dark = Color(0xFF343a40);
  static const sidebar = Color(0xFF222d32);
  static const accent = Color(0xFF28a745);
  static const danger = Color(0xFFdc3545);
  static const warning = Color(0xFFffc107);
  static const info = Color(0xFF17a2b8);
  static const light = Color(0xFFF4F6F9);
  static const gray = Color(0xFF6c757d);
}

final ThemeData adminLteTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: AdminLteColors.light,
  primaryColor: AdminLteColors.primary,
  appBarTheme: AppBarTheme(
    backgroundColor: AdminLteColors.dark,
    foregroundColor: Colors.white,
    elevation: 2,
    titleTextStyle: GoogleFonts.sourceSans3TextTheme().titleLarge?.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: 22,
      color: Colors.white,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: AdminLteColors.sidebar,
  ),
  textTheme: GoogleFonts.sourceSans3TextTheme(),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: AdminLteColors.accent,
    primary: AdminLteColors.primary,
    error: AdminLteColors.danger,
    surface: Colors.white,
  ),
  cardTheme: CardThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 4,
    color: Colors.white,
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AdminLteColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: GoogleFonts.sourceSans3(fontWeight: FontWeight.bold),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    fillColor: Colors.white,
    filled: true,
    labelStyle: GoogleFonts.sourceSans3(color: AdminLteColors.gray),
  ),
);
