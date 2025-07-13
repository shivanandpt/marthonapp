import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marunthon_app/features/menu_drawer/presentation/menu_drawer.dart';
import 'package:marunthon_app/core/services/analytics_service.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/runs/services/run_service.dart';
import 'package:marunthon_app/features/user/user_profile/setup/services/user_service.dart';
import 'package:marunthon_app/features/home/services/training_plan_service.dart';
import 'package:marunthon_app/features/home/services/training_day_service.dart';

// Import BLoC
import 'bloc/home_bloc.dart';
import 'bloc/home_event.dart';

// Import components
import 'components/home_page/home_app_bar.dart';
import 'components/home_page/home_body.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(
        auth: FirebaseAuth.instance,
        userService: UserService(),
        trainingPlanService: TrainingPlanService(),
        trainingDayService: TrainingDayService(),
        runService: RunService(),
      )..add(const LoadHomeData()),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AnalyticsService.setCurrentScreen('HomePage');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Handle app lifecycle changes for both iOS and Android
    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground - refresh data if needed
        if (mounted) {
          context.read<HomeBloc>().add(const RefreshHomeData());
        }
        break;
      case AppLifecycleState.paused:
        // App went to background - save any pending data
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        break;
      case AppLifecycleState.inactive:
        // App is inactive (iOS specific)
        break;
      case AppLifecycleState.hidden:
        // App is hidden (newer Flutter versions)
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HomeAppBar(),
      drawer: const MenuDrawer(),
      body: SafeArea(
        // SafeArea ensures content doesn't overlap with system UI
        child: const HomeBody(),
      ),
      // Add platform-specific behavior for the drawer
      endDrawerEnableOpenDragGesture: true,
      drawerEnableOpenDragGesture: true,
    );
  }
}
