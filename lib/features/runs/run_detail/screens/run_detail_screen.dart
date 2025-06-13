import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import '../../models/run_model.dart';
import '../services/chart_data_processor.dart';
import '../components/run_detail_app_bar.dart';
import '../components/run_detail_header.dart';
import '../components/run_stats_overview.dart';
import '../components/run_route_map.dart';
import '../components/charts_section.dart';
import '../components/debug_map_info.dart';

class RunDetailScreen extends StatelessWidget {
  final RunModel run;

  const RunDetailScreen({super.key, required this.run});

  @override
  Widget build(BuildContext context) {
    final chartData = ChartDataProcessor.processRunData(run);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: RunDetailAppBar(),
      body: ListView(
        children: [
          // Header with date and status
          RunDetailHeader(run: run),

          // Main stats overview
          RunStatsOverview(run: run),

          // Google Maps route
          RunRouteMap(run: run),

          // Performance charts
          ChartsSection(chartData: chartData),

          // Bottom padding
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
