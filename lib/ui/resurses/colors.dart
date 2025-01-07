import 'package:flutter/material.dart';

class AppColors {
  static const green = Color(0xFF40B0A3);
  static const blue = Color(0xFF0A84FF);
  static const blueLight = Color(0xFFE3ECFF);
  static const yellow = Color(0xFFFFC531);
  static const red = Color(0xFFD61D20);
  static const orange = Color(0xFFF25A19);

  // Основные цвета
  static const primary = Color(0xFF6C5CE7); // Насыщенный фиолетовый
  static const secondary = Color(0xFF00D2D3); // Бирюзовый

  // Градиентные пары
  static const primaryGrad1 = Color(0xFF8E2DE2); // Глубокий фиолетовый
  static const primaryGrad2 = Color(0xFF4A00E0); // Электрик фиолетовый

  static const secondaryGrad1 = Color(0xFF00F2FE); // Яркий циан
  static const secondaryGrad2 = Color(0xFF4FACFE); // Светлый синий

  static const accentGrad1 = Color(0xFFF857A6); // Розовый
  static const accentGrad2 = Color(0xFFFF5858); // Коралловый

  // Акцентные цвета
  static const success = Color(0xFF00B894); // Изумрудный
  static const warning = Color(0xFFFED330); // Золотой
  static const error = Color(0xFFFF4757); // Красный коралл
  static const info = Color(0xFF5352ED); // Электрик синий

  // Нейтральные цвета
  static const black = Color(0xFF1E1F29); // Глубокий темный
  static const darkGrey = Color(0xFF2D3436); // Темно-серый
  static const grey = Color(0xFF636E72); // Серый
  static const lightGrey = Color(0xFFB2BEC3); // Светло-серый
  static const white = Color(0xFFFAFAFA); // Почти белый

  // Семантические цвета текста
  static const textPrimary = Color(0xFFFDFDFD); // Основной текст (светлый)
  static const textSecondary = Color(0xFFB2BEC3); // Вторичный текст
  static const textMuted = Color(0xFF636E72); // Приглушенный текст

  // Вспомогательные цвета
  static const backgroundDark = Color.fromARGB(255, 23, 24, 31); // Темный фон
  static const backgroundLight = Color(0xFFF5F6FA); // Светлый фон
  static const surfaceDark = Color(0xFF2D2E36); // Темная поверхность
  static const surfaceLight = Color(0xFFFFFFFF); // Светлая поверхность
}

class AppGradients {
  static const primary = LinearGradient(
    colors: [Color.fromARGB(255, 50, 39, 60), AppColors.primaryGrad2],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const secondary = LinearGradient(
    colors: [AppColors.secondaryGrad1, AppColors.secondaryGrad2],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const accent = LinearGradient(
    colors: [AppColors.accentGrad1, AppColors.accentGrad2],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}