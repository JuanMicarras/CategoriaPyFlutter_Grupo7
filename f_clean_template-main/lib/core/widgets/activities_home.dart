import 'package:flutter/material.dart';

class ActivitiesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

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
                  color: theme.colorScheme.secondary,
                ),
              ),

              Text(
                "View All",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          ActivityCard(),

          SizedBox(height: 16),

          ActivityCard(),

          SizedBox(height: 16),

          ActivityCard(),
        ],
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Container(
      width: 327,
      padding: EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? theme.colorScheme.secondary.withOpacity(0.15)
            : Colors.white,

        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.15),
            offset: Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),

      child: Row(
        children: [
          /// FECHA
          Container(
            width: 60,
            height: 60,

            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.15),
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
                    color: theme.colorScheme.primary,
                  ),
                ),

                Text(
                  "24",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 16),

          /// TEXTO
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
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  "Pendiente • 6:00 PM",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          /// BOTON
          Container(
            width: 32,
            height: 32,

            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.onSurface.withOpacity(0.4)
              ),
            ),

            child: Icon(
              Icons.chevron_right,
              size: 18,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
