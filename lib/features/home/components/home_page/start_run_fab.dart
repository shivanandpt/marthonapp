import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/runs/run_tracking_pag.dart';
import '../../bloc/home_bloc.dart';
import '../../bloc/home_state.dart';

class StartRunFAB extends StatelessWidget {
  const StartRunFAB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoaded) {
          if (state.todaysTraining != null &&
              state.todaysTraining!.id.isNotEmpty) {
            return FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => const RunTrackingPage(
                          //trainingDayId: state.todaysTraining!.id, // UNCOMMENT THIS LINE
                        ),
                  ),
                );
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(LucideIcons.play),
              label: const Text("Start Today's Run"),
            );
          }
        }
        return const SizedBox.shrink(); // No button when loading or error
      },
    );
  }
}
