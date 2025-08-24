import 'dart:math';


import 'package:car_routing_application/features/home/data/datasources/google_places_remote_data_sources.dart';
import 'package:car_routing_application/features/home/domain/entities/location_entity.dart';
import 'package:car_routing_application/features/home/domain/entities/place_suggestions.dart';

import '../../domain/entities/place_details.dart';
import '../../domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  final GooglePlacesRemoteDataSource remote;
  LocationRepositoryImpl({required this.remote});

  @override
  Future<List<PlaceSuggestion>> getSuggestions(
      String input, {
        String? sessionToken,
        String? countryComponent,
      }) {
    return remote.fetchSuggestions(
      input,
      sessionToken: sessionToken,
      countryComponent: countryComponent,
    );
  }

  @override
  Future<PlaceDetails?> getPlaceDetails(
      String placeId, {
        String? sessionToken,
      }) {
    return remote.fetchPlaceDetails(placeId, sessionToken: sessionToken);
  }

  @override
  Future<double> getDistanceTo(double lat, double lng) async {
    return 0;
  }

  @override
  Future<LocationEntity> getCurrentLocation()=> remote.getCurrent();

  @override
  Stream<LocationEntity> watchLocation()=>remote.watch();
}