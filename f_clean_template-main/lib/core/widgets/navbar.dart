import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {

  final int currentIndex;
  final Function(int) onTap;

  const NavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  Alignment getIndicatorAlignment() {
    switch (currentIndex) {
      case 0:
        return Alignment.topLeft;
      case 1:
        return Alignment.topCenter;
      case 2:
        return Alignment.topRight;
      default:
        return Alignment.topCenter;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5)
        ],
      ),
      child: Stack(
        children: [

          /// indicador deslizante
          AnimatedAlign(
            alignment: getIndicatorAlignment(),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              width: MediaQuery.of(context).size.width / 3,
              alignment: Alignment.topCenter,
              child: Container(
                height: 3,
                width: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFAF95DE),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          Row(
            children: [
              Expanded(child: navItem(Icons.menu_book, "Cursos", 0)),
              Expanded(child: navItem(Icons.home, "Home", 1)),
              Expanded(child: navItem(Icons.person, "Perfil", 2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget navItem(IconData icon, String label, int index) {

    bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const SizedBox(height: 10),

            Icon(
              icon,
              color: isSelected ? const Color(0xFFAF95DE) : Colors.grey,
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? const Color(0xFFAF95DE) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
