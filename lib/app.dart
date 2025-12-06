import 'package:flutter/material.dart';
import 'routes/route_generator.dart';
import 'config/app_colors.dart';
import 'config/app_text_styles.dart';
import 'presentation/pages/auth/auth_wrapper.dart'; // Import the new wrapper

class LightningMeetApp extends StatelessWidget {
  const LightningMeetApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData base = ThemeData.light();

    return MaterialApp(
      title: 'Lightning Meet',
      debugShowCheckedModeBanner: false,
      // Set AuthWrapper as the home. It will handle showing login or home.
      home: const AuthWrapper(),
      // onGenerateRoute is still needed for other named routes like /signup
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
