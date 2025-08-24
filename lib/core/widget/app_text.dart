import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_values.dart';

class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? textColor;
  final FontStyle? fontStyle;
  final Function()? onTap;

  const AppText({
    super.key,
    required this.text,
    this.style,
    this.textAlign=TextAlign.center,
    this.maxLines,
    this.overflow=TextOverflow.ellipsis,
    this.fontSize=AppValues.fontSize_14,
    this.fontWeight=FontWeight.normal,
    this.textColor=AppColors.kBlackColor,
    this.fontStyle,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: style ?? TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontStyle: fontStyle
        ),
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}