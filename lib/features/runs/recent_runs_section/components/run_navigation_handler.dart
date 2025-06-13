import 'package:flutter/material.dart';
import 'package:marunthon_app/features/runs/run_detail_page.dart';
import 'package:marunthon_app/features/runs/models/run_model.dart';

class RunNavigationHandler {
  static void navigateToRunDetail(BuildContext context, RunModel run) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => RunDetailPage(run: run),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
