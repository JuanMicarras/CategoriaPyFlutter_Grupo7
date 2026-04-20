import 'package:flutter/material.dart';
import 'package:peer_sync/core/themes/app_theme.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NavBar({super.key, required this.currentIndex, required this.onTap});

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
    final isLight = Theme.of(context).brightness == Brightness.light;

    // Padding dinámico del sistema (para notch y home indicator)
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 70 + bottomPadding,
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppTheme.darkCard,
        boxShadow: [
          BoxShadow(
            color: isLight ? Colors.black12 : const Color(0x1A000000),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        children: [
          /// Indicador deslizante (línea superior)
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
                  color: isLight ? AppTheme.primaryColor : AppTheme.darkPrimarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          /// Botones de navegación
          Row(
            children: [
              Expanded(child: navItem(Icons.layers, "Cursos", 0, isLight)),
              Expanded(child: navItem(Icons.home_rounded, "Home", 1, isLight)),
              Expanded(
                child: navItem(
                  Icons.person_outline_rounded,
                  "Perfil",
                  2,
                  isLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget navItem(IconData icon, String label, int index, bool isLight) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),

            Icon(
              icon,
              size: 26,
              color: isSelected
                  ? (isLight ? AppTheme.primaryColor : AppTheme.darkPrimarySoft)
                  : (isLight ? Colors.grey : AppTheme.darkTextMuted),
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? (isLight ? AppTheme.primaryColor : AppTheme.darkPrimarySoft)
                    : (isLight ? Colors.grey : AppTheme.darkTextMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
