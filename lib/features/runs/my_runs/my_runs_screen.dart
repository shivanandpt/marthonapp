import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marunthon_app/features/runs/models/run_model.dart';
import 'package:marunthon_app/features/runs/services/run_service.dart';
import 'package:marunthon_app/features/runs/run_list/run_list_screen.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MyRunsScreen extends StatefulWidget {
  const MyRunsScreen({Key? key}) : super(key: key);

  @override
  State<MyRunsScreen> createState() => _MyRunsScreenState();
}

class _MyRunsScreenState extends State<MyRunsScreen> {
  final RunService _runService = RunService();
  List<RunModel>? _runs;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRuns();
  }

  Future<void> _loadRuns() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _error = 'Please log in to view your runs';
          _isLoading = false;
        });
        return;
      }

      print('Fetching runs for user: ${user.uid}');
      final runs = await _runService.getUserRuns(user.uid);
      print('Successfully loaded ${runs.length} runs for user ${user.uid}');

      if (mounted) {
        setState(() {
          _runs = runs;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading runs: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to load runs: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onDelete(String runId) async {
    try {
      await _runService.deleteRun(runId);
      print('Run deleted: $runId');

      // Remove the run from the local list
      if (mounted) {
        setState(() {
          _runs = _runs?.where((run) => run.id != runId).toList();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Run deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error deleting run: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete run: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'My Runs',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'My Runs',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.alertCircle, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _loadRuns();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RunListScreen(runs: _runs ?? [], onDelete: _onDelete);
  }
}
