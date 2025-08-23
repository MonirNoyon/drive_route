import 'package:car_routing_application/features/home/domain/entities/place_suggestions.dart';

import 'package:car_routing_application/features/home/domain/entities/place_details.dart';

abstract class LocationRepository {
  Future<List<PlaceSuggestion>> getSuggestions(
      String input, {
        String? sessionToken,
        String? countryComponent,
      });

  Future<PlaceDetails> getPlaceDetails(
      String placeId, {
        String? sessionToken,
      });

  Future<double> getDistanceTo(double lat, double lng);
}