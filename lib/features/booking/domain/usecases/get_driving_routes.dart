import 'package:car_routing_application/features/booking/domain/repositories/direction_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../entities/route_option.dart';
import '../entities/point.dart';

class GetDrivingRoutes {
  final DirectionsRepository repo;
  const GetDrivingRoutes(this.repo);

  Future<List<RouteOption>> call({
    required LatLng origin,
    required LatLng destination,
  }) {
    return repo.getDrivingRoutes(origin: origin, destination: destination);
  }
}