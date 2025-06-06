import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marunthon_app/features/runs/models/run_model.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/features/runs/run_detail/screens/run_detail_screen.dart';

enum SortOption { dateNewest, dateOldest, distanceLongest, distanceShortest }

class RunList extends StatefulWidget {
  final List<RunModel> runs;
  final Function(String runId) onDelete;

  const RunList({super.key, required this.runs, required this.onDelete});

  @override
  State<RunList> createState() => _RunListState();
}

class _RunListState extends State<RunList> {
  SortOption _currentSort = SortOption.dateNewest;

  List<RunModel> _getSortedRuns() {
    List<RunModel> sortedRuns = List.from(widget.runs);

    switch (_currentSort) {
      case SortOption.dateNewest:
        sortedRuns.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case SortOption.dateOldest:
        sortedRuns.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      case SortOption.distanceLongest:
        sortedRuns.sort((a, b) => b.distance.compareTo(a.distance));
        break;
      case SortOption.distanceShortest:
        sortedRuns.sort((a, b) => a.distance.compareTo(b.distance));
        break;
    }

    return sortedRuns;
  }

  String _getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.dateNewest:
        return 'Date (Newest)';
      case SortOption.dateOldest:
        return 'Date (Oldest)';
      case SortOption.distanceLongest:
        return 'Distance (Longest)';
      case SortOption.distanceShortest:
        return 'Distance (Shortest)';
    }
  }

  IconData _getSortIcon(SortOption option) {
    switch (option) {
      case SortOption.dateNewest:
        return LucideIcons.calendar;
      case SortOption.dateOldest:
        return LucideIcons.calendar;
      case SortOption.distanceLongest:
        return LucideIcons.ruler;
      case SortOption.distanceShortest:
        return LucideIcons.ruler;
    }
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.filter, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Sort Runs',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ...SortOption.values.map(
                  (option) => ListTile(
                    leading: Icon(
                      _getSortIcon(option),
                      color:
                          _currentSort == option
                              ? AppColors.primary
                              : AppColors.textSecondary,
                    ),
                    title: Text(
                      _getSortLabel(option),
                      style: TextStyle(
                        color:
                            _currentSort == option
                                ? AppColors.primary
                                : AppColors.textPrimary,
                        fontWeight:
                            _currentSort == option
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                    trailing:
                        _currentSort == option
                            ? Icon(LucideIcons.check, color: AppColors.primary)
                            : null,
                    onTap: () {
                      setState(() {
                        _currentSort = option;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.runs.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.footprints,
                size: 64,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 16),
              Text(
                'No runs yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Start your first run to see it here!',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final sortedRuns = _getSortedRuns();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            // Sort header
            return Container(
              margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.runs.length} runs',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  InkWell(
                    onTap: _showSortOptions,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.secondary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.filter,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 6),
                          Text(
                            _getSortLabel(_currentSort),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            LucideIcons.chevronDown,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Run cards (index - 1 because of header)
          final run = sortedRuns[index - 1];
          return RunCard(run: run, onDelete: widget.onDelete);
        },
        childCount: sortedRuns.length + 1, // +1 for header
      ),
    );
  }
}

class RunCard extends StatelessWidget {
  final RunModel run;
  final Function(String runId) onDelete;

  const RunCard({Key? key, required this.run, required this.onDelete})
    : super(key: key);

  String _formatDuration(int durationSeconds) {
    final duration = Duration(seconds: durationSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return "$hours:$minutes:$seconds";
    } else {
      return "$minutes:$seconds";
    }
  }

  String _formatPace(double distanceKm, int durationSeconds) {
    if (distanceKm == 0) return "0:00";

    double paceMinutesPerKm = durationSeconds / 60.0 / distanceKm;
    int minutes = paceMinutesPerKm.floor();
    int seconds = ((paceMinutesPerKm - minutes) * 60).round();

    return "${minutes}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(run.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 24),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.trash2, color: Colors.white, size: 24),
            SizedBox(height: 4),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor: AppColors.cardBg,
                title: Text(
                  'Delete Run',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                content: Text(
                  'Are you sure you want to delete this run? This action cannot be undone.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      'Delete',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
        );
      },
      onDismissed: (direction) {
        onDelete(run.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Run deleted'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RunDetailScreen(run: run),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        LucideIcons.footprints,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('MMM d, yyyy').format(run.timestamp),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            DateFormat('h:mm a').format(run.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronRight,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        icon: LucideIcons.map,
                        label: "Distance",
                        value: "${run.distance.toStringAsFixed(2)} km",
                        color: AppColors.primary,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        icon: LucideIcons.clock,
                        label: "Duration",
                        value: _formatDuration(run.duration),
                        color: AppColors.secondary,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        icon: LucideIcons.zap,
                        label: "Pace",
                        value: "${_formatPace(run.distance, run.duration)}/km",
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
