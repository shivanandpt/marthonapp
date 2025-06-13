import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';

class DebugMapInfo extends StatelessWidget {
  final List<dynamic> routePoints;

  const DebugMapInfo({super.key, required this.routePoints});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bug_report, color: AppColors.error),
              SizedBox(width: 8),
              Text(
                'Map Debug Info',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildDebugRow('Route Points Count', '${routePoints.length}'),
          _buildDebugRow('Route Points Type', '${routePoints.runtimeType}'),
          if (routePoints.isNotEmpty) ...[
            _buildDebugRow(
              'First Point Type',
              '${routePoints.first.runtimeType}',
            ),
            if (routePoints.first is Map<String, dynamic>) ...[
              _buildDebugRow(
                'First Point Latitude',
                '${routePoints.first['latitude']}',
              ),
              _buildDebugRow(
                'First Point Longitude',
                '${routePoints.first['longitude']}',
              ),
            ],
          ],
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Check Debug Console for:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '• Google Maps API key errors',
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  '• INVALID_REQUEST messages',
                  style: TextStyle(fontSize: 12),
                ),
                Text('• REQUEST_DENIED errors', style: TextStyle(fontSize: 12)),
                Text(
                  '• Network connectivity issues',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
