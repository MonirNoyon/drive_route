import 'package:car_routing_application/core/widget/app_text.dart';
import 'package:flutter/material.dart';
import '/core/constants/app_colors.dart';

class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? label;
  final IconData? icon;
  final ButtonType type;
  final Color? color;
  final Color? textColor;
  final Color? borderColor;
  final double radius;
  final double? iconSize;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;

  const AppButton._({
    this.onPressed,
    this.label,
    this.icon,
    required this.type,
    this.color,
    this.textColor,
    this.borderColor,
    this.radius = 12,
    this.iconSize,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    this.width,
    this.height,
  });

  factory AppButton.border({
    required String label,
    required VoidCallback onPressed,
    Color borderColor = AppColors.kPrimaryColor,
    Color textColor = AppColors.kPrimaryColor,
    double radius = 8,
    EdgeInsetsGeometry? padding,
  }) =>
      AppButton._(
        label: label,
        onPressed: onPressed,
        type: ButtonType.border,
        textColor: textColor,
        borderColor: borderColor,
        radius: radius,
        padding: padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      );

  /// Bordered Icon + Text Button
  factory AppButton.borderIcon({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    Color borderColor = AppColors.kPrimaryColor,
    Color textColor = Colors.deepPurple,
    double radius = 8,
    double iconSize = 18,
    EdgeInsetsGeometry? padding,
  }) =>
      AppButton._(
        label: label,
        icon: icon,
        onPressed: onPressed,
        type: ButtonType.borderIcon,
        textColor: textColor,
        borderColor: borderColor,
        radius: radius,
        iconSize: iconSize,
        padding: padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      );

  /// Filled Text Button
  factory AppButton.fill({
    required String label,
    required VoidCallback onPressed,
    Color color = AppColors.kPrimaryColor,
    Color textColor = AppColors.kWhiteColor,
    double radius = 8,
    EdgeInsetsGeometry? padding,
  }) =>
      AppButton._(
        label: label,
        onPressed: onPressed,
        type: ButtonType.fill,
        color: color,
        textColor: textColor,
        radius: radius,
        padding: padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      );

  /// Filled Icon + Text Button
  factory AppButton.fillIcon({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    Color color = Colors.deepPurple,
    Color textColor = Colors.white,
    double radius = 8,
    double iconSize = 18,
    EdgeInsetsGeometry? padding,
  }) =>
      AppButton._(
        label: label,
        icon: icon,
        onPressed: onPressed,
        type: ButtonType.fillIcon,
        color: color,
        textColor: textColor,
        radius: radius,
        iconSize: iconSize,
        padding: padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      );

  /// Circular Icon Button
  factory AppButton.circularIcon({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 48,
    Color color = Colors.deepPurple,
    Color iconColor = Colors.white,
    double iconSize = 20,
  }) =>
      AppButton._(
        icon: icon,
        onPressed: onPressed,
        type: ButtonType.circularIcon,
        color: color,
        textColor: iconColor,
        radius: size / 2,
        width: size,
        height: size,
        iconSize: iconSize,
        padding: EdgeInsets.zero,
      );

  @override
  Widget build(BuildContext context) {
    Widget child;

    final baseText = AppText(
      text: label ?? '',
      textColor: textColor ?? Colors.white,
      fontWeight: FontWeight.w500,
    );

    switch (type) {
      case ButtonType.fill:
      case ButtonType.border:
        child = baseText;
        break;
      case ButtonType.fillIcon:
      case ButtonType.borderIcon:
        child = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize, color: textColor),
            const SizedBox(width: 8),
            baseText,
          ],
        );
        break;
      case ButtonType.circularIcon:
        child = Icon(icon, size: iconSize, color: textColor);
        break;
    }

    return SizedBox(
      width: width,
      height: height,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            border: _getBorder(),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }

  Color? _getBackgroundColor() {
    switch (type) {
      case ButtonType.fill:
      case ButtonType.fillIcon:
      case ButtonType.circularIcon:
        return color;
      case ButtonType.border:
      case ButtonType.borderIcon:
        return Colors.transparent;
    }
  }

  BoxBorder? _getBorder() {
    switch (type) {
      case ButtonType.border:
      case ButtonType.borderIcon:
        return Border.all(color: borderColor ?? Colors.grey, width: 1.1);
      default:
        return null;
    }
  }
}

enum ButtonType {
  fill,
  fillIcon,
  border,
  borderIcon,
  circularIcon,
}