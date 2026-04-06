import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
//TODO:este widget es muy especifico y no se esta usando
class CourseCodeModal extends StatelessWidget {
  final String title;
  final String code;
  final String codeHintText;
  final String exitText;
  final double width;
  final VoidCallback? onExit;
  final VoidCallback? onCopied;

  const CourseCodeModal({
    super.key,
    this.title = 'Código del Curso',
    this.code = '',
    this.codeHintText = '456-7890',
    this.exitText = 'Salir',
    this.width = 300,
    this.onExit,
    this.onCopied,
  });

  Future<void> _copyCode(BuildContext context) async {
    final valueToCopy = code.isNotEmpty ? code : codeHintText;

    await Clipboard.setData(ClipboardData(text: valueToCopy));

    onCopied?.call();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código copiado al portapapeles')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
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
        children: [
          Text(
            title,
            style: AppTheme.bodyL.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8FB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.grayColor100, width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    code.isNotEmpty ? code : codeHintText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.bodyM.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF637488),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () => _copyCode(context),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.copy_outlined,
                      size: 22,
                      color: AppTheme.textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: onExit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                exitText,
                style: AppTheme.buttonM.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
