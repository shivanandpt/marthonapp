import 'package:flutter/material.dart';
import 'package:marunthon_app/features/runs/models/run_model.dart';
import 'package:marunthon_app/features/runs/run_list/run_list_screen.dart'; // Import the run list screen
import '../components/section_header.dart';
import '../components/run_cards_list.dart';
import '../components/run_navigation_handler.dart';

class RecentRunsSection extends StatelessWidget {
  final List<RunModel> recentRuns;
  final List<RunModel> allRuns; // Add all runs for the list page
  final Function(String runId)? onDelete; // Add delete callback

  const RecentRunsSection({
    super.key,
    required this.recentRuns,
    required this.allRuns,
    this.onDelete,
  });

  void _navigateToRunList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => RunListScreen(
              runs: allRuns,
              onDelete:
                  onDelete ??
                  (String runId) {
                    // Default delete handler if none provided
                    print('Delete run: $runId');
                  },
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with custom navigation
        SectionHeader(
          title: "Recent Runs",
          onActionTap: () => _navigateToRunList(context),
          actionText: "Show all",
        ),
        const SizedBox(height: 12),

        // Recent runs list
        RunCardsList(
          runs: recentRuns,
          onRunTap: RunNavigationHandler.navigateToRunDetail,
          maxItems: 3,
        ),
      ],
    );
  }
}
