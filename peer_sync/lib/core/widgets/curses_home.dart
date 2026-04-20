import 'package:flutter/material.dart';
import 'package:peer_sync/core/themes/app_theme.dart';

class CoursesSection extends StatelessWidget {
  const CoursesSection({super.key});

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
                "Cursos Agregados",
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
          Row(
            children: [
              CourseCard(
                title: "Estructura del\nComputador",
                categories: "3 categorias",
                icon: Icons.waves,
              ),
              const SizedBox(width: 16),
              CourseCard(
                title: "Desarrollo\nMóvil",
                categories: "2 categorias",
                icon: Icons.phone_iphone,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final String title;
  final String categories;
  final IconData icon;

  const CourseCard({
    super.key,
    required this.title,
    required this.categories,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      width: 155.5,
      height: 210,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isLight ? const Color(0x2E000000) : const Color(0x1A000000),
            offset: const Offset(0, 2),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ICONO SUPERIOR
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isLight
                  ? const Color(0xFFE5DBF5)
                  : const Color(0xFF3A2A6B),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: isLight
                  ? const Color(0xFF9877C8)
                  : const Color(0xFFD1C4FF),
            ),
          ),

          const SizedBox(height: 12),

          // TÍTULO
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isLight
                  ? const Color(0xFF2D3748)
                  : AppTheme.darkTextPrimary,
            ),
          ),

          const SizedBox(height: 6),

          // Descripción (Lorem ipsum)
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                "Lorem ipsum dolor sit amet, consectadi...",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  color: isLight
                      ? const Color(0xFF718096)
                      : AppTheme.darkTextMuted,
                ),
              ),
            ),
          ),

          const Spacer(),

          // BADGE DE CATEGORÍAS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isLight
                  ? const Color(0xFFEBE5F7)
                  : const Color(0xFF3A2A6B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.people,
                  size: 14,
                  color: isLight
                      ? const Color(0xFF9877C8)
                      : const Color(0xFFD1C4FF),
                ),
                const SizedBox(width: 4),
                Text(
                  categories,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isLight
                        ? const Color(0xFF9877C8)
                        : const Color(0xFFD1C4FF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
