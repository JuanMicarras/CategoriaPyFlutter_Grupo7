import 'package:flutter/material.dart';

class EvaluationCard extends StatelessWidget {
  const EvaluationCard({super.key});

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
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Envolvemos el texto en Expanded para que no empuje el icono fuera de los 294px
        Expanded(
          child: Text(
            "Last Evaluation",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A202C),
            ),
            overflow: TextOverflow.ellipsis, // Si el texto es muy largo, pone "..."
          ),
        ),
        const SizedBox(width: 8), // Espacio mínimo entre texto e icono
        Icon(Icons.more_horiz, color: Color(0xFF718096)),
      ],
    );
  }
}

class ChartSection extends StatelessWidget {
  const ChartSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
  const BottomSection({super.key});

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
