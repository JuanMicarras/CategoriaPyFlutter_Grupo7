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
        body: Center(child: EvaluationCard()),
      ),
    );
  }
}

class EvaluationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 342,
      padding: EdgeInsets.all(24),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderSection(),
          SizedBox(height: 20),
          ChartSection(),
          SizedBox(height: 20),
          BottomSection(),
        ],
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Last Evaluation",
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Color(0xFFE1D7F3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "Active",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600, // semibold
              color: Color(0xFF8761BE),
            ),
          ),
        ),
      ],
    );
  }
}

class ChartSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      child: CustomPaint(painter: LineChartPainter()),
    );
  }
}

class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint linePaint = Paint()
      ..color = Colors.purple
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    Path path = Path();

    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(50, size.height * 0.3, 100, size.height * 0.6);
    path.quadraticBezierTo(150, size.height * 0.9, 200, size.height * 0.4);
    path.quadraticBezierTo(250, size.height * 0.5, 300, size.height * 0.2);

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BottomSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 138,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "AVERAGE LEVEL",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF718096),
                ),
              ),

              Row(
                children: [
                  Text(
                    "Low",
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),

                  SizedBox(width: 6),

                  Icon(Icons.circle, size: 8, color: Color(0xFF8761BE)),
                ],
              ),
            ],
          ),
        ),

        SizedBox(
          width: 138,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "MOOD SCORE",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF718096),
                ),
              ),

              Row(
                children: [
                  Text(
                    "8.5",
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),

                  SizedBox(width: 6),

                  Icon(Icons.trending_up, color: Color(0xFF8761BE)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
