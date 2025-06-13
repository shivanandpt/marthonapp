import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:marunthon_app/core/widgets/app_button.dart';
import '../../bloc/home_bloc.dart';
import '../../bloc/home_event.dart';

class ErrorView extends StatelessWidget {
  final String errorMessage;

  const ErrorView({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          const SizedBox(height: 16),
          const Text(
            "Unable to Load Dashboard",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppButton(
                onPressed: () {
                  context.read<HomeBloc>().add(const LoadHomeData());
                },
                text: "Retry",
                width: 120,
              ),
              const SizedBox(width: 16),
              AppButton(
                onPressed: () {
                  context.go('/profile-setup');
                },
                text: "Setup Profile",
                backgroundColor: Colors.grey[600],
                width: 140,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
