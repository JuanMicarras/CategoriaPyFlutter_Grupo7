import 'package:flutter/material.dart';
import 'package:peer_sync/core/themes/app_theme.dart';

class ActivityOverviewCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final double width;
  final List<double> barHeights;
  final List<Color>? barColors;

  const ActivityOverviewCard({
    super.key,
    this.title = 'Activity Overview',
    this.subtitle = 'Resultados mayormente excelentes',
    this.icon = Icons.calendar_today_outlined,
    this.width = 330,
    this.barHeights = const [32, 48, 24, 56, 40, 20, 48],
    this.barColors,
  });

  @override
  Widget build(BuildContext context) {
    final colors =
        barColors ??
        const [
          AppTheme.secondaryColor100,
          Color(0xFFA07BD8),
          AppTheme.secondaryColor500,
          AppTheme.primaryColor,
          Color(0xFFC7AEED),
          Color(0xFFA98CDB),
          Color(0xFF9B7AD3),
        ];

    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(24, 22, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E000000),
            offset: Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.bodyL.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTheme.bodyS.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppTheme.secondaryColor500,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 22, color: AppTheme.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(barHeights.length, (index) {
              final color = colors[index % colors.length];

              return _MiniBar(height: barHeights[index], color: color);
            }),
          ),
        ],
      ),
    );
  }
}

class _MiniBar extends StatelessWidget {
  final double height;
  final Color color;

  const _MiniBar({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
