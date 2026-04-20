import 'package:flutter/material.dart';
import 'package:peer_sync/core/themes/app_theme.dart';

class EvaluationCard extends StatelessWidget {
  const EvaluationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      width: 342,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isLight ? const Color(0x2E000000) : const Color(0x1A000000),
            offset: const Offset(0, 3),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderSection(),
          const SizedBox(height: 20),
          ChartSection(),
          const SizedBox(height: 20),
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
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Last Evaluation",
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isLight ? const Color(0xFF2D3748) : AppTheme.darkTextPrimary,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isLight ? const Color(0xFFE1D7F3) : const Color(0xFF3F2A6B),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "Active",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isLight
                  ? const Color(0xFF8761BE)
                  : const Color(0xFFD1C4FF),
            ),
          ),
        ),
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
    final isLight =
        true; // Podemos mejorar esto después si quieres que cambie según tema

    Paint linePaint = Paint()
      // ignore: dead_code
      ..color = isLight ? Colors.purple : Color(0xFFCCBBE3)
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
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Average Level
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
                  color: isLight
                      ? const Color(0xFF718096)
                      : AppTheme.darkTextMuted,
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
                      color: isLight
                          ? const Color(0xFF2D3748)
                          : AppTheme.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: isLight
                        ? const Color(0xFF8761BE)
                        : const Color(0xFFD1C4FF),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Mood Score
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
                  color: isLight
                      ? const Color(0xFF718096)
                      : AppTheme.darkTextMuted,
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
                      color: isLight
                          ? const Color(0xFF2D3748)
                          : AppTheme.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.trending_up,
                    color: isLight
                        ? const Color(0xFF8761BE)
                        : const Color(0xFFD1C4FF),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
