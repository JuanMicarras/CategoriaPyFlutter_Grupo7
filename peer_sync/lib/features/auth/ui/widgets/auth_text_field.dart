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
  final bool isLoginPassword;

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
    this.isLoginPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isPassword) {
      return Obx(() {
        final isObscure = isLoginPassword
            ? controller.obscureLoginPassword.value
            : controller.obscureSignUpPassword.value;

        final toggleFunction = isLoginPassword
            ? controller.toggleLoginPasswordVisibility
            : controller.toggleSignUpPasswordVisibility;

        return TextField(
          controller: controllerText,
          readOnly: readOnly,
          obscureText: isObscure,
          onChanged: onChanged ?? controller.validatePassword,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black87
                : AppTheme.darkTextPrimary.withOpacity(0.8),
          ),
          decoration: InputDecoration(
            fillColor: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : AppTheme.darkInputBackground,
            hoverColor: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : AppTheme.darkInputBackground,
            hintText: hint,
            hintStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black38
                  : Colors.white30,
            ),
            prefixIcon: Icon(
              icon,
              color: Theme.of(context).brightness == Brightness.light
                  ? AppTheme.primaryColor.withOpacity(0.6)
                  : AppTheme.darkTextPrimary.withOpacity(0.6),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
                onPressed: toggleFunction,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.light
                    ? AppTheme.primaryColor.withOpacity(0.8)
                    : AppTheme.darkPrimarySoft.withOpacity(0.8),
                width: 2.0,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 20,
            ),
          ),
        );
      });
    }

    if (isEmail) {
      return TextField(
        controller: controllerText,
        readOnly: readOnly,
        keyboardType: TextInputType.emailAddress,
        onChanged: onChanged ?? controller.validateEmail,
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black87
              : AppTheme.darkTextPrimary.withOpacity(0.8),
        ),
        decoration: InputDecoration(
          fillColor: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : AppTheme.darkInputBackground,
          hoverColor: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : AppTheme.darkInputBackground,
          hintText: hint,
          hintStyle: TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black38
                : Colors.white30,
          ),
          prefixIcon: Icon(
            icon,
            color: Theme.of(context).brightness == Brightness.light
                ? AppTheme.primaryColor.withOpacity(0.6)
                : AppTheme.darkTextPrimary.withOpacity(0.6),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppTheme.primaryColor.withOpacity(0.8)
                  : AppTheme.darkPrimarySoft.withOpacity(0.8),
              width: 2.0,
            ),
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
      style: TextStyle(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.black87
            : AppTheme.darkTextPrimary.withOpacity(0.8),
      ),
      decoration: InputDecoration(
        fillColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : AppTheme.darkInputBackground,
        hoverColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : AppTheme.darkInputBackground,
        hintText: hint,
        hintStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black38
              : Colors.white30,
        ),
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).brightness == Brightness.light
              ? AppTheme.primaryColor.withOpacity(0.6)
              : AppTheme.darkTextPrimary.withOpacity(0.6),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).brightness == Brightness.light
                ? AppTheme.primaryColor.withOpacity(0.8)
                : AppTheme.darkPrimarySoft.withOpacity(0.8),
            width: 2.0,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 20,
        ),
      ),
    );
  }
}
