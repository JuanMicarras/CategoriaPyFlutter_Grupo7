// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';

class AuthTextField extends GetView<AuthController> {
  final String hint;
  final IconData icon;
  final bool isPassword;
  final bool isEmail;
  final bool readOnly;
  final TextEditingController controllerText;
  final String? errorText;
  final Function(String)? onChanged;

  const AuthTextField({
    super.key,
    required this.hint,
    required this.icon,
    required this.controllerText,
    this.isPassword = false,
    this.readOnly = false,
    this.isEmail = false,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isPassword) {
      return Obx(
        () => TextField(
          controller: controllerText,
          readOnly: readOnly,
          obscureText: controller.obscurePassword.value,
          onChanged: onChanged ?? controller.validatePassword,
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            fillColor: Colors.white,
            hoverColor: Colors.white,
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38),
            prefixIcon: Icon(
              icon,
              color: AppTheme.primaryColor.withOpacity(0.6),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                icon: Icon(
                  controller.obscurePassword.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 20,
            ),
          ),
        ),
      );
    }

    if (isEmail) {
      return TextField(
        controller: controllerText,
        readOnly: readOnly,
        keyboardType: TextInputType.emailAddress,
        onChanged: onChanged ?? controller.validateEmail,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          fillColor: Colors.white,
          hoverColor: Colors.white,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38),
          prefixIcon: Icon(icon, color: AppTheme.primaryColor.withOpacity(0.6)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 20,
          ),
        ),
      );
    }

    // Campo genérico (nombre, etc.)
    return TextField(
      controller: controllerText,
      readOnly: readOnly,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        fillColor: Colors.white,
        hoverColor: Colors.white,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor.withOpacity(0.6)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 20,
        ),
      ),
    );
  }
}
