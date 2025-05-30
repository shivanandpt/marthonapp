import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marunthon_app/features/log_run/run_detail_page.dart';
import 'package:marunthon_app/models/run_model.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/core/services/run_service.dart';

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

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final day = dayKeys[index];
        final runs = grouped[day]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day separator
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
                      DateFormat(
                        'EEE, MMM d, yyyy',
                      ).format(DateTime.parse(day)),
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
            ...runs.map(
              (run) => Dismissible(
                key: ValueKey(run.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  color: AppColors.error,
                  child: Icon(Icons.delete, color: Colors.white, size: 32),
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
                      Icons.directions_run,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      "${run.distance.toStringAsFixed(2)} m",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      "${DateFormat('HH:mm').format(run.timestamp)}  •  ${Duration(seconds: run.duration).toString().split('.').first}",
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
              ),
            ),
          ],
        );
      }, childCount: dayKeys.length),
    );
  }
}
