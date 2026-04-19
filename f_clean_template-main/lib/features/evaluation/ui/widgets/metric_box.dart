import 'package:flutter/material.dart';
import 'package:peer_sync/core/themes/app_theme.dart';

class MetricBox extends StatelessWidget {
  final String title;
  final String value;

  const MetricBox({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTheme.bodyS.copyWith(
              fontSize: 11,
              color: AppTheme.grayColor500,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTheme.bodyL.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textColor,
            ),
          ),
        ],
      ),
    );
  }
}
