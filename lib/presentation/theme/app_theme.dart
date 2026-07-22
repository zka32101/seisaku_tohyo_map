import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// アプリ全体のカラー・タイポグラフィ・共通スタイルを一元管理
class AppColors {
  AppColors._();

  // ブランドカラー
  static const primary = Color(0xFF2563EB); // 青（信頼・情報）
  static const primaryLight = Color(0xFFEFF6FF);

  // 課題カテゴリカラー（設計書準拠）
  static const populationBlue = Color(0xFF3B82F6); // 人口減少
  static const pensionOrange = Color(0xFFF97316); // 年金
  static const careGreen = Color(0xFF10B981); // 介護
  static const politicsPurple = Color(0xFF8B5CF6); // 政治
  static const debtRed = Color(0xFFEF4444); // 国債
  static const structuralTeal = Color(0xFF0D9488); // 本質的・構造的課題

  // ステータスカラー
  static const danger = Color(0xFFDC2626); // 赤字
  static const dangerLight = Color(0xFFFEF2F2);
  static const success = Color(0xFF059669); // 黒字
  static const successLight = Color(0xFFF0FDF4);

  // ニュートラル
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9CA3AF);
  static const background = Color(0xFFF9FAFB);
  static const surface = Colors.white;
  static const border = Color(0xFFE5E7EB);

  static Color categoryColor(String category) {
    switch (category) {
      case 'economy':
        return pensionOrange;
      case 'welfare':
        return careGreen;
      case 'demographic':
        return populationBlue;
      case 'politics':
        return politicsPurple;
      case 'debt':
        return debtRed;
      case 'structural':
        return structuralTeal;
      default:
        return textSecondary;
    }
  }

  static String categoryLabel(String category) {
    switch (category) {
      case 'economy':
        return '経済';
      case 'welfare':
        return '福祉';
      case 'demographic':
        return '人口';
      case 'politics':
        return '政治';
      case 'debt':
        return '財政';
      case 'structural':
        return '政治構造';
      default:
        return category;
    }
  }

  static IconData categoryIcon(String category) {
    switch (category) {
      case 'economy':
        return Icons.payments_outlined;
      case 'welfare':
        return Icons.favorite_outline;
      case 'demographic':
        return Icons.groups_outlined;
      case 'politics':
        return Icons.account_balance_outlined;
      case 'debt':
        return Icons.trending_down_outlined;
      case 'structural':
        return Icons.hub_outlined;
      default:
        return Icons.help_outline;
    }
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoSansJp(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      // 端末のシステムフォントだと一部の漢字が中国語字形（簡体字寄り）に
      // フォールバックして表示されることがあるため、日本語字形のNoto Sans JPを明示的に使用
      textTheme: GoogleFonts.notoSansJpTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}

/// 共通で使う角丸カード・余白などのスタイル定数
class AppSpacing {
  AppSpacing._();
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

class AppRadius {
  AppRadius._();
  static const card = 16.0;
  static const button = 14.0;
  static const badge = 8.0;
}
