import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/home/models/training_day_model.dart';
import 'details/modal_header.dart';
import 'details/modal_content.dart';

class TrainingDayDetailsModal {
  static void show(BuildContext context, TrainingDayModel day) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ModalHeader(day: day),
              SizedBox(height: 16),
              ModalContent(day: day),
              SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
