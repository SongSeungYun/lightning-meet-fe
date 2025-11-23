import 'package:flutter/material.dart';
import 'config/app_routes.dart';
import 'routes/route_generator.dart';
import 'config/app_colors.dart';
import 'config/app_text_styles.dart';

class LightningMeetApp extends StatelessWidget {
  const LightningMeetApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData base = ThemeData.light();

    return MaterialApp(
      title: 'Lightning Meet',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.login,
      onGenerateRoute: RouteGenerator.generateRoute,
      theme: base.copyWith(
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          foregroundColor: AppColors.textPrimary,
        ),
        textTheme: base.textTheme.copyWith(
          titleLarge: AppTextStyles.titleLarge,
          titleMedium: AppTextStyles.titleMedium,
          bodyMedium: AppTextStyles.body,
        ),
        colorScheme: base.colorScheme.copyWith(
          primary: AppColors.primary,
          secondary: AppColors.primaryLight,
        ),
      ),
    );
  }
}
