import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:marunthon_app/features/home/bloc/home_bloc.dart';
import 'package:marunthon_app/features/home/bloc/home_state.dart';
import 'home_content.dart';
import 'loading_view.dart';
import 'no_user_view.dart';
import 'error_view.dart';

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
          return HomeContent(state: state);
        }

        return const SizedBox.shrink();
      },
    );
  }
}
