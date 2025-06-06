import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marunthon_app/features/home/bloc/home_bloc.dart';
import 'package:marunthon_app/features/home/bloc/home_state.dart';
import 'package:marunthon_app/features/home/components/home_page/quick_start_menu.dart';
import 'loading_view.dart';
import 'no_user_view.dart';
import 'error_view.dart';
import 'home_content.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeProfileNotFound) {
          context.go('/profile-setup');
        } else if (state is HomeError &&
            state.message.contains('not authenticated')) {
          context.go('/login');
        }
      },
      builder: (context, state) {
        if (state is HomeLoading || state is HomeInitial) {
          return const LoadingView();
        }

        if (state is HomeProfileNotFound) {
          return const NoUserView();
        }

        if (state is HomeError) {
          return ErrorView(errorMessage: state.message);
        }

        if (state is HomeLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100), // Space for FAB
            child: Column(
              children: [
                // Add QuickStartMenu at the top
                const QuickStartMenu(),

                // ... your existing home body content
                // Today's workout, recent runs, stats, etc.
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
