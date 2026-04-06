import 'package:flutter/material.dart';
import 'package:peer_sync/core/themes/app_theme.dart';

// Le quitamos el "_" inicial para que sea pública
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
    super.key, // Buena práctica añadir el key
    required this.title,
    required this.month,
    required this.day,
    required this.statusTag,
    required this.statusDetail,
    required this.dateBgColor,
    required this.dateTextColor,
    required this.onTap,
  });

  ({Color background, Color text, Color border}) _tagColors(String value) {
    final normalized = value.toLowerCase().trim();

    if (normalized.contains('pendiente') || normalized.contains('en curso')) {
      return (
        background: const Color(0xFFF3EDFF),
        text: const Color(0xFF7F56D9),
        border: const Color(0xFFE4D7FF),
      );
    }

    if (normalized.contains('próximamente') ||
        normalized.contains('proximamente') || 
        normalized.contains('programada')) {
      return (
        background: const Color(0xFFEAF2FF),
        text: const Color(0xFF3B82F6),
        border: const Color(0xFFD7E5FF),
      );
    }

    if (normalized.contains('vencida') || normalized.contains('finalizada')) {
      return (
        background: const Color(0xFFF3F4F6),
        text: const Color(0xFF6B7280),
        border: const Color(0xFFE5E7EB),
      );
    }

    return (
      background: const Color(0xFFF3F4F6),
      text: const Color(0xFF667085),
      border: const Color(0xFFE5E7EB),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tagStyle = _tagColors(statusTag);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2E000000),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            children: [
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.bodyL.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
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
                        Text(
                          statusDetail,
                          style: AppTheme.bodyS.copyWith(
                            color: const Color(0xFF718096),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
                ),
                child: const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}