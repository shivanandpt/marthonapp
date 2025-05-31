import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marunthon_app/core/routes/app_routes.dart';
import 'package:marunthon_app/features/auth/presentation/login_page.dart';
import 'package:marunthon_app/features/home/home_page.dart';
import 'package:marunthon_app/features/auth/presentation/auth_wrapper.dart';
import 'firebase_options.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(MyApp());
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marathon Training',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.background,
          error: AppColors.error,
        ),
        cardColor: AppColors.cardBg,
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          bodyMedium: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32), // Nike/Strava style
            ),
            textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
        ),
      ),
      darkTheme: ThemeData.dark(),
      home: AuthWrapper(), // Check authentication status
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
