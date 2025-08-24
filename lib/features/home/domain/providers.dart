import 'package:car_routing_application/features/home/data/providers.dart';
import 'package:car_routing_application/features/home/domain/entities/place_suggestions.dart';
import 'package:car_routing_application/features/home/domain/usecases/get_current_location.dart';
import 'package:car_routing_application/features/home/domain/usecases/get_distance_place.dart';
import 'package:car_routing_application/features/home/domain/usecases/watch_location_stream.dart';
import 'package:car_routing_application/features/home/presentation/controller/map_controller.dart';
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

final getCurrentLocationProvider = Provider(
      (ref) => GetCurrentLocation(ref.read(locationRepositoryProvider)),
);

final watchLocationStreamProvider = Provider(
      (ref) => WatchLocationStream(ref.read(locationRepositoryProvider)),
);

final mapControllerProvider = StateNotifierProvider<MapController, MapState>((ref) {
  return MapController(
    getCurrent: ref.read(getCurrentLocationProvider),
    watchLocation: ref.read(watchLocationStreamProvider),
  )..init();
});

final pickupSuggestionsProvider = StateProvider.autoDispose<List<PlaceSuggestion>>((ref) => []);
final dropOffSuggestionsProvider = StateProvider.autoDispose<List<PlaceSuggestion>>((ref) => []);