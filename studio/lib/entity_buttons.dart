import 'package:flutter/material.dart';

class EntityButtons extends StatelessWidget {
  final VoidCallback onEdit;
  final bool visible;

  const EntityButtons({super.key, required this.onEdit, required this.visible});

  @override
  Widget build(BuildContext context) {
    return
}

class _EntityButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const _EntityButton({required this.child, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: child,
    );
  }
}
