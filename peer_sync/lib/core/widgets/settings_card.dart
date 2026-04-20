import 'package:flutter/material.dart';
import 'package:peer_sync/core/themes/app_theme.dart';

class SettingsCardItem {
  final String title;
  final VoidCallback? onTap;

  const SettingsCardItem({required this.title, this.onTap});
}

class SettingsCard extends StatelessWidget {
  final List<SettingsCardItem> items;
  final double width;

  const SettingsCard({
    super.key,
    this.width = 330,
    this.items = const [
      SettingsCardItem(title: 'Notificaciones'),
      SettingsCardItem(title: 'Privacidad y seguridad'),
      SettingsCardItem(title: 'Cerrar sesión'),
    ],
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
        mainAxisSize: MainAxisSize.min,
        children: List.generate(items.length, (index) {
          final item = items[index];

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SettingsRow(title: item.title, onTap: item.onTap),
              if (index != items.length - 1) const _SettingsDivider(),
            ],
          );
        }),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const _SettingsRow({required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTheme.bodyM.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isLight
                      ? AppTheme.textColor
                      : AppTheme.darkTextPrimary,
                ),
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isLight ? AppTheme.grayColor100 : AppTheme.darkBorder,
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
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Divider(
      height: 1,
      thickness: 1,
      color: isLight ? const Color(0xFFE5E7EB) : AppTheme.darkBorder,
    );
  }
}
