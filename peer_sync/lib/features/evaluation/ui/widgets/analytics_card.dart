import 'package:flutter/material.dart';
import 'package:peer_sync/core/themes/app_theme.dart';

class AnalyticsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget chart;
  final Widget? footer;
  final Widget? trailing;

  const AnalyticsCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.chart,
    this.footer,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppTheme.darkCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isLight ? const Color(0x14000000) : const Color(0x1A000000),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.bodyL.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isLight
                            ? AppTheme.textColor
                            : AppTheme.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTheme.bodyS.copyWith(
                        fontSize: 13,
                        color: isLight
                            ? AppTheme.darkTextMuted.withOpacity(0.8)
                            : AppTheme.darkTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 18),
          chart,
          if (footer != null) ...[const SizedBox(height: 18), footer!],
        ],
      ),
    );
  }
}
