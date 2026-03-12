import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';

class AuthTextField extends GetView<AuthController> {
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controllerText;

  const AuthTextField({
    super.key,
    required this.hint,
    required this.icon,
    required this.controllerText,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPassword) {
      return TextField(
        controller: controllerText,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          fillColor: Colors.white,
          hoverColor: Colors.white,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38),
          prefixIcon: Icon(icon, color: AppTheme.primaryColor.withOpacity(0.6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 20,
          ),
        ),
      );
    }

    return Obx(
      () => TextField(
        controller: controllerText,
        obscureText: controller.obscurePassword.value,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          fillColor: Colors.white,
          hoverColor: Colors.white,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38),
          prefixIcon: Icon(icon, color: AppTheme.primaryColor.withOpacity(0.6)),
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
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 20,
          ),
        ),
      ),
    );
  }
}
