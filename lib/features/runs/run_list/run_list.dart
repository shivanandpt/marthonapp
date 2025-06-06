import 'package:flutter/material.dart';
import 'package:marunthon_app/features/runs/models/run_model.dart';
import 'components/sort_option_enum.dart';
import 'components/sort_utils.dart';
import 'components/empty_runs_state.dart';
import 'components/run_list_header.dart';
import 'components/run_card.dart';

class RunList extends StatefulWidget {
  final List<RunModel> runs;
  final Function(String runId) onDelete;

  const RunList({super.key, required this.runs, required this.onDelete});

  @override
  State<RunList> createState() => _RunListState();
}

class _RunListState extends State<RunList> {
  SortOption _currentSort = SortOption.dateNewest;

  List<RunModel> get _sortedRuns =>
      SortUtils.getSortedRuns(widget.runs, _currentSort);

  @override
  Widget build(BuildContext context) {
    if (widget.runs.isEmpty) {
      return const EmptyRunsState();
    }

    final sortedRuns = _sortedRuns;

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == 0) {
          return RunListHeader(
            runCount: widget.runs.length,
            currentSort: _currentSort,
            onSortChanged: (sortOption) {
              setState(() {
                _currentSort = sortOption;
              });
            },
          );
        }

        final run = sortedRuns[index - 1];
        return RunCard(run: run, onDelete: widget.onDelete);
      }, childCount: sortedRuns.length + 1),
    );
  }
}
