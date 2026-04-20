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
    final isLight = Theme.of(context).brightness == Brightness.light;

    // Colores de las barras adaptados a dark mode
    final colors =
        barColors ??
        (isLight
            ? const [
                AppTheme.secondaryColor100,
                Color(0xFFA07BD8),
                AppTheme.secondaryColor500,
                AppTheme.primaryColor,
                Color(0xFFC7AEED),
                Color(0xFFA98CDB),
                Color(0xFF9B7AD3),
              ]
            : const [
                Color(0xFF9F7EDB), // Versión más clara en dark
                Color(0xFFB89BE6),
                Color(0xFFCCB8F0),
                AppTheme.darkPrimaryLight,
                Color(0xFFD4C4F5),
                Color(0xFFBB9EE8),
                Color(0xFFA98CDB),
              ]);

    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(24, 22, 20, 20),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppTheme.darkCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isLight ? const Color(0x2E000000) : const Color(0x1A000000),
            offset: const Offset(0, 3),
            blurRadius: 6,
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
                        fontWeight: FontWeight.w400,
                        color: isLight
                            ? const Color(0xFF6B7280)
                            : AppTheme.darkTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isLight
                      ? AppTheme.secondaryColor500
                      : AppTheme.darkPrimarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: isLight ? AppTheme.primaryColor : Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),

          // Barras
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
