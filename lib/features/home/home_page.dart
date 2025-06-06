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
      create:
          (context) => HomeBloc(
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

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    AnalyticsService.setCurrentScreen('HomePage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HomeAppBar(),
      drawer: const MenuDrawer(),
      body: const HomeBody(),
    );
  }
}
