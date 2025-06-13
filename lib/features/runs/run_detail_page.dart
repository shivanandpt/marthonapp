import 'package:flutter/material.dart';
import 'models/run_model.dart';
import 'run_detail/screens/run_detail_screen.dart';

class RunDetailPage extends StatelessWidget {
  final RunModel run;

  const RunDetailPage({super.key, required this.run});

  @override
  Widget build(BuildContext context) {
    return RunDetailScreen(run: run);
  }
}
