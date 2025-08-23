import 'point.dart';
import 'bounds.dart';

class RouteOption {
  final int index;
  final int meters;
  final String distanceText;
  final String durationText;
  final List<Point> points;  // polyline decoded
  final Bounds bounds;

  const RouteOption({
    required this.index,
    required this.meters,
    required this.distanceText,
    required this.durationText,
    required this.points,
    required this.bounds,
  });
}