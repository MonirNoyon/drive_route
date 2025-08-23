import 'package:car_routing_application/features/home/data/providers.dart';
import 'package:car_routing_application/features/home/domain/entities/place_suggestions.dart';
import 'package:car_routing_application/features/home/domain/usecases/get_distance_place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/usecases/get_place_details.dart';
import '../domain/usecases/get_place_suggestions.dart';
import '../domain/repositories/location_repository.dart';

final getPlaceSuggestionsProvider = Provider<GetPlaceSuggestions>((ref) {
  final repo = ref.watch(locationRepositoryProvider);
  return GetPlaceSuggestions(repo);
});

final getPlaceDetailsProvider = Provider<GetPlaceDetails>((ref) {
  final repo = ref.watch(locationRepositoryProvider);
  return GetPlaceDetails(repo);
});

final getDistanceToPlaceProvider = Provider<GetDistanceToPlace>((ref) {
  final repo = ref.watch(locationRepositoryProvider);
  return GetDistanceToPlace(repo);
});

/// If you also want to expose the repo to presentation:
final locationRepositoryProviderAlias = Provider<LocationRepository>((ref) {
  return ref.watch(locationRepositoryProvider);
});

final pickupSuggestionsProvider = StateProvider.autoDispose<List<PlaceSuggestion>>((ref) => []);
final dropOffSuggestionsProvider = StateProvider.autoDispose<List<PlaceSuggestion>>((ref) => []);