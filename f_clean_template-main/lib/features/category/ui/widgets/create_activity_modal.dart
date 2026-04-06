import 'package:flutter/material.dart';
import 'package:peer_sync/core/themes/app_theme.dart';

class CreateActivityModal extends StatelessWidget {
  final TextEditingController? nameController;
  final TextEditingController? startDateController;
  final TextEditingController? endDateController;
  final TextEditingController? startTimeController;
  final TextEditingController? endTimeController;

  final VoidCallback? onCancel;
  final VoidCallback? onCreate;
  final VoidCallback? onTapStartDate;
  final VoidCallback? onTapEndDate;
  final VoidCallback? onTapStartTime;
  final VoidCallback? onTapEndTime;
  final ValueChanged<bool>? onPublicChanged;

  final bool isPublic;
  final double width;

  const CreateActivityModal({
    super.key,
    this.nameController,
    this.startDateController,
    this.endDateController,
    this.startTimeController,
    this.endTimeController,
    this.onCancel,
    this.onCreate,
    this.onTapStartDate,
    this.onTapEndDate,
    this.onTapStartTime,
    this.onTapEndTime,
    this.onPublicChanged,
    this.isPublic = false,
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
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Crear Actividad',
            style: AppTheme.bodyL.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 14),
          _ModalLabel(text: 'Nombre (*)'),
          const SizedBox(height: 6),
          _TextInputField(controller: nameController, hintText: 'Taller 1'),
          const SizedBox(height: 12),
          _ModalLabel(text: 'Fecha Inicio'),
          const SizedBox(height: 6),
          _DateInputField(
            controller: startDateController,
            hintText: 'DD / MM / YY',
            onTap: onTapStartDate,
          ),
          const SizedBox(height: 12),
          _ModalLabel(text: 'Fecha Fin'),
          const SizedBox(height: 6),
          _DateInputField(
            controller: endDateController,
            hintText: 'DD / MM / YY',
            onTap: onTapEndDate,
          ),
          const SizedBox(height: 12),
          _ModalLabel(text: 'Hora Inicio'),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _TimeInputField(
                  controller: startTimeController,
                  hintText: 'HH : MM',
                  onTap: onTapStartTime,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '-',
                  style: AppTheme.bodyM.copyWith(
                    fontSize: 18,
                    color: AppTheme.textColor,
                  ),
                ),
              ),
              Expanded(
                child: _TimeInputField(
                  controller: endTimeController,
                  hintText: 'HH : MM',
                  onTap: onTapEndTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scale: 0.95,
                child: Switch(
                  value: isPublic,
                  onChanged: onPublicChanged,
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppTheme.primaryColor,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: const Color(0xFFD1D5DB),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Publico',
                style: AppTheme.bodyM.copyWith(
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF637488),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
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
                      'Cancelar',
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
                    onPressed: onCreate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Crear',
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

class _ModalLabel extends StatelessWidget {
  final String text;

  const _ModalLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: AppTheme.bodyM.copyWith(
          fontWeight: FontWeight.w400,
          color: const Color(0xFF637488),
        ),
      ),
    );
  }
}

class _TextInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;

  const _TextInputField({required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.secondaryColor, width: 1),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
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
    );
  }
}

class _DateInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final VoidCallback? onTap;

  const _DateInputField({
    required this.controller,
    required this.hintText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.secondaryColor, width: 1),
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: AppTheme.bodyM.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF94A3B8),
          ),
          suffixIcon: const Icon(
            Icons.calendar_today_outlined,
            size: 20,
            color: Color(0xFF94A3B8),
          ),
        ),
        style: AppTheme.bodyM.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppTheme.textColor,
        ),
      ),
    );
  }
}

class _TimeInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final VoidCallback? onTap;

  const _TimeInputField({
    required this.controller,
    required this.hintText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.secondaryColor, width: 1),
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: AppTheme.bodyS.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF94A3B8),
          ),
          suffixIcon: const Icon(
            Icons.access_time_outlined,
            size: 20,
            color: Color(0xFF94A3B8),
          ),
        ),
        style: AppTheme.bodyS.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppTheme.textColor,
        ),
      ),
    );
  }
}
