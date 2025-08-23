import 'package:car_routing_application/features/home/domain/entities/place_suggestions.dart';

import 'package:car_routing_application/features/home/domain/repositories/location_repository.dart';

class GetPlaceSuggestions {
  final LocationRepository repo;
  GetPlaceSuggestions(this.repo);

  Future<List<PlaceSuggestion>> call(
      String input, {
        String? sessionToken,
        String? countryComponent,
      }) {
    return repo.getSuggestions(
      input,
      sessionToken: sessionToken,
      countryComponent: countryComponent,
    );
  }
}