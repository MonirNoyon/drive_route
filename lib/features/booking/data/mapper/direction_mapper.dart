import '../../domain/entities/point.dart';
import '../../domain/entities/bounds.dart';
import '../../domain/entities/route_option.dart';

class DirectionsMapper {
  static List<RouteOption> mapToRouteOptions(Map<String, dynamic> json) {
    final routes = (json['routes'] as List?) ?? [];
    final List<RouteOption> out = [];

    for (int i = 0; i < routes.length; i++) {
      final r = routes[i] as Map<String, dynamic>;
      final polyStr = r['overview_polyline']?['points'] as String?;
      if (polyStr == null) continue;

      final points = _decodePolyline(polyStr);

      // Bounds from decoded points
      double? minLat, minLng, maxLat, maxLng;
      for (final p in points) {
        minLat = (minLat == null) ? p.lat : (p.lat < minLat ? p.lat : minLat);
        minLng = (minLng == null) ? p.lng : (p.lng < minLng ? p.lng : minLng);
        maxLat = (maxLat == null) ? p.lat : (p.lat > maxLat ? p.lat : maxLat);
        maxLng = (maxLng == null) ? p.lng : (p.lng > maxLng ? p.lng : maxLng);
      }
      final bounds = Bounds(
        southwest: Point(minLat ?? 0, minLng ?? 0),
        northeast: Point(maxLat ?? 0, maxLng ?? 0),
      );

      // Sum meters, capture texts from legs
      int meters = 0;
      String? distText;
      String? durText;
      final legs = (r['legs'] as List?) ?? [];
      for (final leg in legs) {
        final m = (leg['distance']?['value'] as int?) ?? 0;
        meters += m;
        distText ??= leg['distance']?['text'] as String?;
        durText  ??= leg['duration']?['text'] as String?;
      }

      out.add(
        RouteOption(
          index: i,
          meters: meters,
          distanceText: distText ?? '${(meters / 1000).toStringAsFixed(1)} km',
          durationText: durText ?? '',
          points: points,
          bounds: bounds,
        ),
      );
    }

    // Sort shortest first
    out.sort((a, b) => a.meters.compareTo(b.meters));
    return out;
  }

  // Polyline decoder -> domain Points
  static List<Point> _decodePolyline(String encoded) {
    final List<Point> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      poly.add(Point(lat / 1e5, lng / 1e5));
    }
    return poly;
  }
}