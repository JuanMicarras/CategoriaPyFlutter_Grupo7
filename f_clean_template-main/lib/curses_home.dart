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
        body: Center(child: CoursesSection()),
      ),
    );
  }
}

class CoursesSection extends StatelessWidget {
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
                "Cursos Agregados",
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

          /// FILA DE TARJETAS
          Row(
            children: [
              CourseCard(
                title: "Estructura del\nComputador",
                categories: "3 categorias",
                icon: Icons.waves,
              ),

              SizedBox(width: 16),

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
    required this.title,
    required this.categories,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 155.5,
      height: 210,

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

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ICONO SUPERIOR
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFFE5DBF5),
              shape: BoxShape.circle,
            ),

            child: Icon(icon, size: 20, color: Color(0xFF9877C8)),
          ),

          SizedBox(height: 12),

          /// TITULO
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),

          SizedBox(height: 6),

          /// DESCRIPCIÓN
          Text(
            "Lorem ipsum dolor sit amet, consectadi...",
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              color: Color(0xFF718096),
            ),
          ),

          Spacer(),

          /// BADGE DE CATEGORÍAS
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),

            decoration: BoxDecoration(
              color: Color(0xFFEBE5F7),
              borderRadius: BorderRadius.circular(8),
            ),

            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people, size: 14, color: Color(0xFF9877C8)),

                SizedBox(width: 4),

                Text(
                  categories,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9877C8),
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
