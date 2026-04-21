import 'package:flutter/material.dart';
import 'package:peer_sync/core/themes/app_theme.dart';

class MetricBox extends StatelessWidget {
  final String title;
  final String value;

  const MetricBox({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTheme.bodyS.copyWith(
              fontSize: 11,
              color: isLight ? AppTheme.darkTextMuted.withOpacity(0.8) : AppTheme.darkTextMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTheme.bodyL.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isLight ? AppTheme.textColor : AppTheme.darkTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
