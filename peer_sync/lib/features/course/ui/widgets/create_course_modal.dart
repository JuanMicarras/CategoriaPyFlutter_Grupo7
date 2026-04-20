import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:peer_sync/core/themes/app_theme.dart';

class CreateCourseModal extends StatefulWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onCreate;
  final TextEditingController? nameController;
  final String nameHintText;
  final String title;
  final String nameLabel;
  final String categoryLabel;
  final String importCsvText;
  final String cancelText;
  final String createText;
  final double width;
  final ValueChanged<PlatformFile?>? onCsvSelected;

  const CreateCourseModal({
    super.key,
    this.onCancel,
    this.onCreate,
    this.nameController,
    this.nameHintText = 'Programación Móvil',
    this.title = 'Crear Curso',
    this.nameLabel = 'Nombre (*)',
    this.categoryLabel = 'Categoria de Grupo (opc)',
    this.importCsvText = 'Importar CSV',
    this.cancelText = 'Cancelar',
    this.createText = 'Crear',
    this.width = 300,
    this.onCsvSelected,
  });

  @override
  State<CreateCourseModal> createState() => _CreateCourseModalState();
}

class _CreateCourseModalState extends State<CreateCourseModal> {
  String? _selectedFileName;

  Future<void> _pickCsvFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv'],
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;

    setState(() {
      _selectedFileName = file.name;
    });

    widget.onCsvSelected?.call(file);
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      width: widget.width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isLight ? const Color(0x2E000000) : const Color(0x1A000000),
            offset: const Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: AppTheme.bodyL.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isLight ? AppTheme.textColor : AppTheme.darkTextPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.nameLabel,
              style: AppTheme.bodyM.copyWith(
                fontWeight: FontWeight.w400,
                color: isLight
                    ? const Color(0xFF637488)
                    : AppTheme.darkTextMuted,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: isLight
                  ? const Color(0xFFF8F8FB)
                  : AppTheme.darkInputBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isLight ? AppTheme.grayColor100 : AppTheme.darkBorder,
                width: 1,
              ),
            ),
            child: TextField(
              key: const Key('course_name_input'),
              controller: widget.nameController,
              maxLines: 1,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                hintText: widget.nameHintText,
                hintStyle: AppTheme.bodyM.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: isLight
                      ? const Color(0xFF637488)
                      : AppTheme.darkTextMuted,
                ),
              ),
              style: AppTheme.bodyM.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: isLight ? AppTheme.textColor : AppTheme.darkTextPrimary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.categoryLabel,
              style: AppTheme.bodyM.copyWith(
                fontWeight: FontWeight.w400,
                color: isLight
                    ? const Color(0xFF637488)
                    : AppTheme.darkTextMuted,
              ),
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            key: const Key('import_csv_button'),
            onTap: _pickCsvFile,
            borderRadius: BorderRadius.circular(10),
            child: DottedBorder(
              color: isLight
                  ? AppTheme.secondaryColor
                  : AppTheme.darkPrimarySoft,
              strokeWidth: 1.4,
              dashPattern: const [6, 4],
              borderType: BorderType.RRect,
              radius: const Radius.circular(10),
              child: Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isLight
                      ? const Color(0xFFF9F6FF)
                      : AppTheme.darkInputBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      size: 20,
                      color: isLight
                          ? AppTheme.secondaryColor100
                          : AppTheme.darkPrimarySoft,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _selectedFileName ?? widget.importCsvText,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.buttonM.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isLight
                              ? AppTheme.secondaryColor100
                              : AppTheme.darkPrimarySoft,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppTheme.primaryColor,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: isLight
                          ? Colors.white
                          : AppTheme.darkCard,
                    ),
                    child: Text(
                      widget.cancelText,
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
                    key: const Key('submit_course_button'),
                    onPressed: widget.onCreate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.createText,
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
