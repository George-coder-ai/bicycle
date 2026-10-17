import 'package:flutter/material.dart';

/// App-wide color palette tailored for Bicycle Maintenance Log.
/// Meets the project requirements:
/// Primary: Teal (#009688)
/// Secondary: Blue (#42A5F5)
/// Accent: Orange (#FFB74D)
/// Additional accent: Purple (#9575CD)
/// Background: Light (#F8FAFC)
/// Cards: White (#FFFFFF)
class AppColors {
  // Required Core Colors
  static const Color primary = Color(0xFF009688);
  static const Color primaryDark = Color(0xFF00796B);
  static const Color primaryLight = Color(0xFFB2DFDB);
  static const Color secondary = Color(0xFF42A5F5);
  static const Color accent = Color(0xFFFFB74D);
  static const Color accentPurple = Color(0xFF9575CD);
  static const Color background = Color(0xFFF8FAFC);
  static const Color card = Color(0xFFFFFFFF);

  // Pastel Card Backgrounds for Statistics
  static const Color pastelTeal = Color(0xFFE0F2F1);
  static const Color pastelBlue = Color(0xFFE3F2FD);
  static const Color pastelOrange = Color(0xFFFFF3E0);
  static const Color pastelPurple = Color(0xFFEDE7F6);
  static const Color pastelGreen = Color(0xFFE8F5E9);

  // Status Colors for Service Reminders
  static const Color statusUpcoming = Color(0xFF2E7D32); // Green
  static const Color statusUpcomingBg = Color(0xFFE8F5E9);
  static const Color statusDueToday = Color(0xFFEF6C00); // Orange
  static const Color statusDueTodayBg = Color(0xFFFFF3E0);
  static const Color statusOverdue = Color(0xFFC62828); // Red
  static const Color statusOverdueBg = Color(0xFFFFEBEE);

  // Neutral Colors for text & borders
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color shadow = Color(0x0D000000);
}
