import 'package:flutter/material.dart';
import 'package:peer_sync/core/themes/app_theme.dart';

class AddCourseModal extends StatelessWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onAdd;
  final TextEditingController? codeController;
  final String title;
  final String codeHintText;
  final String cancelText;
  final String addText;
  final double width;

  const AddCourseModal({
    super.key,
    this.onCancel,
    this.onAdd,
    this.codeController,
    this.title = 'Agregar Curso',
    this.codeHintText = '456-7890',
    this.cancelText = 'Cancelar',
    this.addText = 'Agregar',
    this.width = 300,
  });

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
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 0),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8FB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.grayColor100, width: 1),
            ),
            child: TextField(
              controller: codeController,
              maxLength: 11,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                hintText: codeHintText,
                counterText: '',
                hintStyle: AppTheme.bodyM.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF637488),
                ),
              ),
              style: AppTheme.bodyM.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppTheme.textColor,
              ),
            ),
            
          ),
          
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppTheme.primaryColor,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      cancelText,
                      style: AppTheme.buttonM.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: onAdd,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      addText,
                      style: AppTheme.buttonM.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
