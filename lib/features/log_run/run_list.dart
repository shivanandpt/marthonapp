import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marunthon_app/features/log_run/run_detail_page.dart';
import 'package:marunthon_app/models/run_model.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RunList extends StatefulWidget {
  final List<RunModel> runs;
  final Function(String runId) onDelete;

  const RunList({super.key, required this.runs, required this.onDelete});

  @override
  State<RunList> createState() => _RunListState();
}

class _RunListState extends State<RunList> {
  Map<String, List<RunModel>> _groupRunsByDay() {
    Map<String, List<RunModel>> grouped = {};
    for (var run in widget.runs) {
      final day = DateFormat('yyyy-MM-dd').format(run.timestamp);
      grouped.putIfAbsent(day, () => []).add(run);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupRunsByDay();
    final dayKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    // Find the earliest run date
    DateTime? firstRunDate;
    if (widget.runs.isNotEmpty) {
      firstRunDate = widget.runs
          .map((run) => run.timestamp)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      // Set to the start of that week (Monday)
      firstRunDate = firstRunDate.subtract(
        Duration(days: firstRunDate.weekday - 1),
      );
    }

    int weekNumberFromFirstRun(DateTime date) {
      if (firstRunDate == null) return 1;
      final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
      return ((startOfWeek.difference(firstRunDate!).inDays) / 7).floor() + 1;
    }

    int dayOfWeek(DateTime date) => date.weekday; // Monday=1, Sunday=7

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final day = dayKeys[index];
        final runs = grouped[day]!;
        final date = DateTime.parse(day);
        final weekNo = weekNumberFromFirstRun(date);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day separator (unchanged)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(color: AppColors.secondary, thickness: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      DateFormat('EEE, MMM d, yyyy').format(date),
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: AppColors.secondary, thickness: 1),
                  ),
                ],
              ),
            ),
            ...runs.map((run) {
              final dayNo = dayOfWeek(run.timestamp);
              return Dismissible(
                key: ValueKey(run.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  color: AppColors.error,
                  child: Icon(LucideIcons.trash, color: Colors.white, size: 32),
                ),
                onDismissed: (direction) async {
                  widget.onDelete(run.id);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Run deleted++')));
                },
                child: Card(
                  color: AppColors.cardBg,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: Icon(
                      LucideIcons.footprints,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      "Week $weekNo / Day $dayNo",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      "${run.distance.toStringAsFixed(2)} km",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RunDetailPage(run: run),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ],
        );
      }, childCount: dayKeys.length),
    );
  }
}
