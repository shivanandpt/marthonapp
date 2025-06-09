import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:marunthon_app/core/routes/app_routes.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';

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
    return MaterialApp.router(
      title: 'Marathon Training',
      theme: AppTheme.darkTheme.copyWith(extensions: [AppTheme.extension]),
      routerConfig: AppRoutes().router,
    );
  }
}
