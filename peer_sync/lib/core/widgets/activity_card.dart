import 'package:flutter/material.dart';
import 'package:peer_sync/core/themes/app_theme.dart';

class ActivityStatusCard extends StatelessWidget {
  final String title;
  final String month;
  final String day;
  final String statusTag;
  final String statusDetail;
  final Color dateBgColor;
  final Color dateTextColor;
  final VoidCallback onTap;

  const ActivityStatusCard({
    super.key,
    required this.title,
    required this.month,
    required this.day,
    required this.statusTag,
    required this.statusDetail,
    required this.dateBgColor,
    required this.dateTextColor,
    required this.onTap,
  });

  ({Color background, Color text, Color border}) _tagColors(
    String value,
    bool isLight,
  ) {
    final normalized = value.toLowerCase().trim();

    if (normalized.contains('pendiente') || normalized.contains('en curso')) {
      return (
        background: isLight ? const Color(0xFFF3EDFF) : const Color(0xFF3F2A6B),
        text: isLight ? const Color(0xFF7F56D9) : const Color(0xFFD1C4FF),
        border: isLight ? const Color(0xFFE4D7FF) : const Color(0xFF5A4A8C),
      );
    }

    if (normalized.contains('próximamente') ||
        normalized.contains('proximamente') ||
        normalized.contains('programada')) {
      return (
        background: isLight ? const Color(0xFFEAF2FF) : const Color(0xFF2A3F6B),
        text: isLight ? const Color(0xFF3B82F6) : const Color(0xFF93C5FD),
        border: isLight ? const Color(0xFFD7E5FF) : const Color(0xFF4A6B9E),
      );
    }

    if (normalized.contains('vencida') || normalized.contains('finalizada')) {
      return (
        background: isLight ? const Color(0xFFF3F4F6) : AppTheme.darkSurface,
        text: isLight ? const Color(0xFF6B7280) : AppTheme.darkTextMuted,
        border: isLight ? const Color(0xFFE5E7EB) : AppTheme.darkBorder,
      );
    }

    // Default
    return (
      background: isLight ? const Color(0xFFF3F4F6) : AppTheme.darkSurface,
      text: isLight ? const Color(0xFF667085) : AppTheme.darkTextMuted,
      border: isLight ? const Color(0xFFE5E7EB) : AppTheme.darkBorder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final tagStyle = _tagColors(statusTag, isLight);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
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
            children: [
              // FECHA
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: dateBgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      month,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: dateTextColor,
                      ),
                    ),
                    Text(
                      day,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: dateTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Contenido principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.bodyL.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isLight
                            ? AppTheme.textColor
                            : AppTheme.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        // Tag de estado
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: tagStyle.background,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: tagStyle.border,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            statusTag,
                            style: AppTheme.bodyS.copyWith(
                              color: tagStyle.text,
                              fontWeight: FontWeight.w700,
                              fontSize: 11.5,
                              height: 1,
                            ),
                          ),
                        ),
                        // Detalle (hora, etc.)
                        Text(
                          statusDetail,
                          style: AppTheme.bodyS.copyWith(
                            color: isLight
                                ? const Color(0xFF718096)
                                : AppTheme.darkTextMuted,
                          ),
                        ),
                      ],
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
                        ? const Color(0xFFD1D5DB)
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
