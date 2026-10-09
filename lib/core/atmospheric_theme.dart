import 'package:flutter/material.dart';

class AtmosphericTheme {
  final LinearGradient bgGradient;
  final Color cardBg;
  final Color cardBorder;
  final Color textColor;
  final Color subtitleColor;
  final Color accentColor;
  final bool isDarkTheme;

  const AtmosphericTheme({
    required this.bgGradient,
    required this.cardBg,
    required this.cardBorder,
    required this.textColor,
    required this.subtitleColor,
    required this.accentColor,
    required this.isDarkTheme,
  });

  static AtmosphericTheme getTheme({
    required int weatherCode,
    required bool isDay,
    required String themeMode, // 'dark', 'light', 'oled', 'system'
    Brightness? systemBrightness,
  }) {
    final bool effectiveDark = switch (themeMode) {
      'oled' => true,
      'dark' => true,
      'light' => false,
      _ => systemBrightness == Brightness.dark || !isDay,
    };

    if (themeMode == 'oled') {
      return const AtmosphericTheme(
        bgGradient: LinearGradient(
          colors: [Colors.black, Color(0xFF09090B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        cardBg: Color(0xFF09090B),
        cardBorder: Color(0xFF27272A),
        textColor: Color(0xFFF4F4F5),
        subtitleColor: Color(0xFFA1A1AA),
        accentColor: Color(0xFF22D3EE),
        isDarkTheme: true,
      );
    }

    if (effectiveDark) {
      // Thunderstorm
      if ([95, 96, 99].contains(weatherCode)) {
        return const AtmosphericTheme(
          bgGradient: LinearGradient(
            colors: [Color(0xFF030712), Color(0xFF2E1065), Color(0xFF030712)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          cardBg: Color(0xCC0F172A),
          cardBorder: Color(0x4D7C3AED),
          textColor: Color(0xFFF8FAFC),
          subtitleColor: Color(0xFF94A3B8),
          accentColor: Color(0xFFA78BFA),
          isDarkTheme: true,
        );
      }
      // Rain
      if ([51, 53, 55, 61, 63, 65, 80, 81, 82].contains(weatherCode)) {
        return const AtmosphericTheme(
          bgGradient: LinearGradient(
            colors: [Color(0xFF020617), Color(0xFF172554), Color(0xFF020617)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          cardBg: Color(0xCC0F172A),
          cardBorder: Color(0x4D1E40AF),
          textColor: Color(0xFFF8FAFC),
          subtitleColor: Color(0xFF94A3B8),
          accentColor: Color(0xFF60A5FA),
          isDarkTheme: true,
        );
      }
      // Snow
      if ([71, 73, 75, 77, 85, 86].contains(weatherCode)) {
        return const AtmosphericTheme(
          bgGradient: LinearGradient(
            colors: [Color(0xFF020617), Color(0xFF082F49), Color(0xFF020617)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          cardBg: Color(0xCC0F172A),
          cardBorder: Color(0x4D0284C7),
          textColor: Color(0xFFF8FAFC),
          subtitleColor: Color(0xFF94A3B8),
          accentColor: Color(0xFF7DD3FC),
          isDarkTheme: true,
        );
      }
      // Default Night
      return const AtmosphericTheme(
        bgGradient: LinearGradient(
          colors: [Color(0xFF020617), Color(0xFF0F172A), Color(0xFF020617)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        cardBg: Color(0xCC0F172A),
        cardBorder: Color(0x33334155),
        textColor: Color(0xFFF8FAFC),
        subtitleColor: Color(0xFF94A3B8),
        accentColor: Color(0xFF818CF8),
        isDarkTheme: true,
      );
    } else {
      // Light Mode
      // Severe / Storm
      if ([95, 96, 99].contains(weatherCode)) {
        return const AtmosphericTheme(
          bgGradient: LinearGradient(
            colors: [Color(0xFFE2E8F0), Color(0xFFEDE9FE), Color(0xFFF1F5F9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          cardBg: Color(0xF2FFFFFF),
          cardBorder: Color(0xFFCBD5E1),
          textColor: Color(0xFF0F172A),
          subtitleColor: Color(0xFF64748B),
          accentColor: Color(0xFF7C3AED),
          isDarkTheme: false,
        );
      }
      // Rain
      if ([51, 53, 55, 61, 63, 65, 80, 81, 82].contains(weatherCode)) {
        return const AtmosphericTheme(
          bgGradient: LinearGradient(
            colors: [Color(0xFFE0F2FE), Color(0xFFEFF6FF), Color(0xFFF8FAFC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          cardBg: Color(0xF2FFFFFF),
          cardBorder: Color(0xFFBAE6FD),
          textColor: Color(0xFF0F172A),
          subtitleColor: Color(0xFF64748B),
          accentColor: Color(0xFF0284C7),
          isDarkTheme: false,
        );
      }
      // Sunny Day
      if ([0, 1].contains(weatherCode)) {
        return const AtmosphericTheme(
          bgGradient: LinearGradient(
            colors: [Color(0xFFFEF3C7), Color(0xFFE0F2FE), Color(0xFFF8FAFC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          cardBg: Color(0xF2FFFFFF),
          cardBorder: Color(0xFFFDE68A),
          textColor: Color(0xFF0F172A),
          subtitleColor: Color(0xFF64748B),
          accentColor: Color(0xFFD97706),
          isDarkTheme: false,
        );
      }
      // Cloudy Day
      return const AtmosphericTheme(
        bgGradient: LinearGradient(
          colors: [Color(0xFFF1F5F9), Color(0xFFE2E8F0), Color(0xFFF8FAFC)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        cardBg: Color(0xF2FFFFFF),
        cardBorder: Color(0xFFCBD5E1),
        textColor: Color(0xFF0F172A),
        subtitleColor: Color(0xFF64748B),
        accentColor: Color(0xFF0284C7),
        isDarkTheme: false,
      );
    }
  }
}
