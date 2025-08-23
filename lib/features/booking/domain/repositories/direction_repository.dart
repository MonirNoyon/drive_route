import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../entities/route_option.dart';
import '../entities/point.dart';

abstract class DirectionsRepository {
  Future<List<RouteOption>> getDrivingRoutes({
    required LatLng origin,
    required LatLng destination,
  });
}