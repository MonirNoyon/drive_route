import 'package:car_routing_application/features/booking/data/datasources/google_distance_remote_data_sources.dart';
import 'package:car_routing_application/features/booking/data/mapper/direction_mapper.dart';
import 'package:car_routing_application/features/booking/domain/repositories/direction_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/point.dart';
import '../../domain/entities/route_option.dart';

class DirectionsRepositoryImpl implements DirectionsRepository {
  final DirectionsRemoteDataSource remote;
  DirectionsRepositoryImpl({required this.remote});

  @override
  Future<List<RouteOption>> getDrivingRoutes({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final json = await remote.fetchRoutesJson(
      origin: origin,
      destination: destination,
    );
    return DirectionsMapper.mapToRouteOptions(json);
  }
}