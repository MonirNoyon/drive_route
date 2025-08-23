import 'package:car_routing_application/core/utils/helper_utils.dart';

enum ColoredLogger {
  red("31"),
  green("32"),
  yellow("33"),
  blue("34"),
  magenta("35"),
  cyan("36");

  final String code;

  const ColoredLogger(this.code);

  void log(dynamic text) {
    printData('\x1B[${code}m$text\x1B[0m');
  }
}