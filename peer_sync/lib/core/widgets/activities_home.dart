import 'package:flutter/material.dart';
import 'package:peer_sync/core/themes/app_theme.dart';

class ActivitiesSection extends StatelessWidget {
  const ActivitiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Actividades Agregadas",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isLight
                      ? AppTheme.secondaryColor
                      : AppTheme.darkTextSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const ActivityCard(),
          const SizedBox(height: 16),
          const ActivityCard(),
          const SizedBox(height: 16),
          const ActivityCard(),
        ],
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  const ActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      width: 327,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isLight
                ? const Color(0x2E000000)
                : const Color(0x1E000000), // Sombra más suave en dark
            offset: const Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // FECHA
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isLight
                  ? const Color(0xFFE5DBF5)
                  : const Color(0xFF3A2A6B),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "OCT",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isLight
                        ? const Color(0xFF8761BE)
                        : const Color(0xFFD1C4FF),
                  ),
                ),
                Text(
                  "24",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isLight
                        ? const Color(0xFF8761BE)
                        : const Color(0xFFD1C4FF),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // TEXTO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Actividad 1",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isLight
                        ? const Color(0xFF2D3748)
                        : AppTheme.darkTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Pendiente • 6:00 PM",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: isLight
                        ? const Color(0xFF718096)
                        : AppTheme.darkTextMuted,
                  ),
                ),
              ],
            ),
          ),

          // BOTÓN
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isLight ? const Color(0xFFD1D5DB) : AppTheme.darkBorder,
              ),
            ),
            child: Icon(
              Icons.chevron_right,
              size: 18,
              color: isLight ? const Color(0xFF718096) : AppTheme.darkTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}
