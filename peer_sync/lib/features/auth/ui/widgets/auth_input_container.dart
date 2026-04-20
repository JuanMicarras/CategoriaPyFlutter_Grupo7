import 'package:flutter/material.dart';
import 'package:peer_sync/core/themes/app_theme.dart';

class AuthInputContainer extends StatelessWidget {
  final List<Widget> children;

  const AuthInputContainer({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light ? Colors.white : AppTheme.darkInputBackground,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.2),
            offset: const Offset(0, 2),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}
