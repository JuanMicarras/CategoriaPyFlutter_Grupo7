import 'package:flutter/material.dart';
import 'package:peer_sync/core/themes/app_theme.dart';

class ProjectCategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final IconData leadingIcon;
  final double width;

  const ProjectCategoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.leadingIcon = Icons.api_rounded,
    this.width = 327,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: isLight ? Colors.white : AppTheme.darkCard,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isLight
                    ? const Color(0x2E000000)
                    : const Color(0x1A000000),
                offset: const Offset(0, 2),
                blurRadius: 6,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono circular
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isLight
                      ? AppTheme.secondaryColor500
                      : const Color(0xFF3F2A6B), // Fondo más oscuro en dark
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  leadingIcon,
                  color: isLight
                      ? AppTheme.primaryColor
                      : const Color(0xFFD1C4FF),
                  size: 22,
                ),
              ),

              const SizedBox(width: 16),

              // Contenido textual
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.bodyL.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isLight
                            ? AppTheme.textColor
                            : AppTheme.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTheme.bodyS.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isLight
                            ? const Color(0xFF718096)
                            : AppTheme.darkTextMuted,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Botón flecha
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isLight
                        ? AppTheme.grayColor100
                        : AppTheme.darkBorder,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: isLight
                      ? const Color(0xFF9CA3AF)
                      : AppTheme.darkTextMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
