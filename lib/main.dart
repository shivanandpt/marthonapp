import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:marunthon_app/core/router.dart';
import 'package:marunthon_app/features/auth/presentation/auth_wrapper.dart';
import 'firebase_options.dart';

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
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: AuthWrapper(), // Check authentication status
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
