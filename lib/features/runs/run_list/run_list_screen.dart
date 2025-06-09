import 'package:flutter/material.dart';
import 'package:marunthon_app/features/runs/models/run_model.dart';
import 'package:marunthon_app/features/runs/run_list/run_list.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RunListScreen extends StatelessWidget {
  final List<RunModel> runs;
  final Function(String runId) onDelete;

  const RunListScreen({super.key, required this.runs, required this.onDelete});

  @override
  Widget build(BuildContext context) {
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
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(top: 16),
            sliver: RunList(runs: runs, onDelete: onDelete),
          ),
        ],
      ),
    );
  }
}
