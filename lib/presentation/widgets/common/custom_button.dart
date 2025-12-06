import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isFullWidth;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isPrimary = true,
    this.isFullWidth = true,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style;

    if (isOutlined) {
      style = OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      );
    } else {
      style = ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? AppColors.primary : AppColors.primaryLight,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }

    final child = Text(
      label,
      style: AppTextStyles.button,
    );

    Widget button;
    if (isOutlined) {
      button = OutlinedButton(
        onPressed: onPressed,
        style: style,
        child: child,
      );
    } else {
      button = ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: child,
      );
    }

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    } else {
      return button;
    }
  }
}
