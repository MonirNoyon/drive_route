import 'dart:math';


import 'package:car_routing_application/features/home/data/datasources/google_places_remote_data_sources.dart';
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
  Future<PlaceDetails> getPlaceDetails(
      String placeId, {
        String? sessionToken,
      }) {
    return remote.fetchPlaceDetails(placeId, sessionToken: sessionToken);
  }

  @override
  Future<double> getDistanceTo(double lat, double lng) async {
    return 0;
  }
    // Permissions & current position
  //   final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     throw StateError('Location services are disabled.');
  //   }
  //
  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       throw StateError('Location permission denied.');
  //     }
  //   }
  //   if (permission == LocationPermission.deniedForever) {
  //     throw StateError('Location permission permanently denied.');
  //   }
  //
  //   final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //
  //   // Haversine distance in meters
  //   double toRad(double deg) => deg * pi / 180.0;
  //   const r = 6371000.0; // Earth radius (m)
  //   final dLat = toRad(lat - pos.latitude);
  //   final dLng = toRad(lng - pos.longitude);
  //   final a = (sin(dLat / 2) * sin(dLat / 2)) +
  //       cos(toRad(pos.latitude)) * cos(toRad(lat)) *
  //           (sin(dLng / 2) * sin(dLng / 2));
  //   final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  //   return r * c;
  // }
}