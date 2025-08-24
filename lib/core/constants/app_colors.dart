import 'package:flutter/material.dart';

abstract class AppColors {
  static const kPrimaryColor = Color(0xFF28C16D);
  static const kPageBackColor1 = Color(0xFFFFFFFF);
  static const kTransparentColor = Colors.transparent;
  static const kBlackColor = Color(0xFF000000);
  static const kWhiteColor = Color(0xFFFFFFFF);
  static List<Color> blackShadowColorList = [
    Colors.black.withValues(alpha: 0.5),
    Colors.black.withValues(alpha: 0.1),
    Colors.transparent,
  ];

  static Color getCustomColour(String colorCode) {
    String inputString = colorCode;
    if (inputString.startsWith("#")) {
      inputString = inputString.substring(1);
    }
    String code = '0xFF$inputString';
    Color customColor = kPrimaryColor;
    try {
      customColor = Color(int.parse(code));
    } catch (e) {
      customColor = kPrimaryColor;
    }
    return customColor;
  }
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
