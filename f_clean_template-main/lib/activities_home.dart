import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[200],
        body: Center(child: ActivitiesSection()),
      ),
    );
  }
}

class ActivitiesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Actividades Agregadas",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFAF95DE),
                ),
              ),

              Text(
                "View All",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFBF94FF),
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
    return Container(
      width: 327,
      padding: EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: Color(0x2E000000),
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
              color: Color(0xFFE5DBF5),
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
                    color: Color(0xFF8761BE),
                  ),
                ),

                Text(
                  "24",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8761BE),
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
                    color: Color(0xFF2D3748),
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  "Pendiente • 6:00 PM",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: Color(0xFF718096),
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
              border: Border.all(color: Color(0xFFD1D5DB)),
            ),

            child: Icon(
              Icons.chevron_right,
              size: 18,
              color: Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }
}
