import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, night }

class AppEngine {
  static String getGreeting(String? userName) {
    final hour = DateTime.now().hour;
    final name = (userName != null && userName.trim().isNotEmpty)
        ? userName.trim()
        : "User";

    if (hour >= 5 && hour < 12) {
      return "Good Morning, $name";
    } else if (hour >= 12 && hour < 17) {
      return "Good Afternoon, $name";
    } else if (hour >= 17 && hour < 21) {
      return "Good Evening, $name";
    } else {
      return "Good Night, $name";
    }
  }

  static String? getFestivalWish(String? userName) {
    final now = DateTime.now();
    final key = "${now.month}-${now.day}";
    final name = (userName != null && userName.trim().isNotEmpty)
        ? userName.trim()
        : "User";

    final Map<String, String> festivals = {
      "1-1": "Happy New Year, $name. Wishing you a creative year ahead.",
      "1-26": "Happy Republic Day, $name.",
      "2-14": "Happy Valentine's Day, $name.",
      "3-14": "Happy Holi, $name. May your designs be full of vibrant colors.",
      "4-22": "Happy Earth Day, $name.",
      "8-15": "Happy Independence Day, $name.",
      "10-31": "Happy Halloween, $name.",
      "11-8": "Happy Diwali, $name. May your life shine bright.",
      "12-25": "Merry Christmas, $name.",
    };

    return festivals[key];
  }

  static ThemeData getThemeData(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          cardColor: Colors.white,
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1A73E8),
            surface: Colors.white,
          ),
          fontFamily: 'Inter',
        );
      case AppThemeMode.dark:
        return ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF1E1E24),
          cardColor: const Color(0xFF2A2A32),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF64B5F6),
            surface: Color(0xFF2A2A32),
          ),
          fontFamily: 'Inter',
        );
      case AppThemeMode.night:
        return ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF000000),
          cardColor: const Color(0xFF0D0D0D),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFBB86FC),
            surface: Color(0xFF0D0D0D),
          ),
          fontFamily: 'Inter',
        );
    }
  }
}
