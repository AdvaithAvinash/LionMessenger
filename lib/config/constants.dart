import 'package:flutter/material.dart';

class LionColors {
  // Primary gradient colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4834D4);
  static const Color primaryLight = Color(0xFF9B8FFF);

  // Accent
  static const Color accent = Color(0xFFFF6584);
  static const Color accentGreen = Color(0xFF43E97B);

  // Light theme
  static const Color backgroundLight = Color(0xFFF8F9FF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color dividerLight = Color(0xFFF3F4F6);

  // Dark theme
  static const Color backgroundDark = Color(0xFF0D0D1A);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color cardDark = Color(0xFF16213E);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF2A2A4A);
  static const Color dividerDark = Color(0xFF1E1E35);

  // Status colors
  static const Color online = Color(0xFF23D18B);
  static const Color away = Color(0xFFFBBC04);
  static const Color busy = Color(0xFFED4245);
  static const Color offline = Color(0xFF6B7280);

  // Message bubble colors
  static const Color myBubbleLight = Color(0xFF6C63FF);
  static const Color theirBubbleLight = Color(0xFFF3F4F6);
  static const Color myBubbleDark = Color(0xFF6C63FF);
  static const Color theirBubbleDark = Color(0xFF1E1E35);

  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF4834D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient splashGradient = LinearGradient(
    colors: [Color(0xFF0D0D1A), Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class LionSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class LionRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 999.0;
}

class LionDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
}

class AppConstants {
  static const String appName = 'LionMessenger';
  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://localhost:3000',
  );
  static const String clerkPublishableKey = String.fromEnvironment(
    'CLERK_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_your_key_here',
  );
  static const String streamApiKey = String.fromEnvironment(
    'STREAM_API_KEY',
    defaultValue: 'your_stream_key',
  );
}
