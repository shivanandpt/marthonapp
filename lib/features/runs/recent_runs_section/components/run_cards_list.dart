import 'package:flutter/material.dart';
import 'package:marunthon_app/features/runs/models/run_model.dart';
import 'run_card.dart';

class RunCardsList extends StatelessWidget {
  final List<RunModel> runs;
  final Function(BuildContext, RunModel) onRunTap;
  final int maxItems;

  const RunCardsList({
    super.key,
    required this.runs,
    required this.onRunTap,
    this.maxItems = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          runs.take(maxItems).map((run) {
            return RunCard(run: run, onTap: () => onRunTap(context, run));
          }).toList(),
    );
  }
}
