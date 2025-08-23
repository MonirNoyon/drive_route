import 'package:car_routing_application/config/api_client/update_api_client.dart';
import 'package:car_routing_application/config/env.dart';
import 'package:car_routing_application/features/booking/data/datasources/google_distance_remote_data_sources.dart';
import 'package:car_routing_application/features/booking/data/repositories/direction_repository_implementer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/domain/entities/place_details.dart';
import '../../domain/entities/point.dart';
import '../../domain/usecases/get_driving_routes.dart';
import '../states/route_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final routeControllerProvider =
StateNotifierProvider<RouteController, RouteState>((ref) {
  throw UnimplementedError('Provide params with routeControllerFamily');
});

final routeControllerFamily =
StateNotifierProvider.family<RouteController, RouteState, (PlaceDetails, PlaceDetails)>((ref, params) {
  final (pickup, dropoff) = params;
  final getRoutes = ref.read(getDrivingRoutesProvider);
  return RouteController(getRoutes: getRoutes, pickup: pickup, dropoff: dropoff)..load();
});

final getDrivingRoutesProvider = Provider<GetDrivingRoutes>((ref) {
  final ds = DirectionsRemoteDataSourceImpl(ApiClient());
  final repo = DirectionsRepositoryImpl(remote: ds);
  return GetDrivingRoutes(repo);
});

class RouteController extends StateNotifier<RouteState> {
  final GetDrivingRoutes getRoutes;
  final PlaceDetails pickup;
  final PlaceDetails dropoff;

  GoogleMapController? mapController;

  RouteController({
    required this.getRoutes,
    required this.pickup,
    required this.dropoff,
  }) : super(RouteState.initial());

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final routes = await getRoutes.call(
        origin: LatLng(pickup.lat, pickup.lng),
        destination: LatLng(dropoff.lat, dropoff.lng),
      );

      final selected = routes.isNotEmpty ? routes.first.index : null;

      state = state.copyWith(
        loading: false,
        routes: routes,
        selectedIndex: selected,
        error: null,
      );

      await _fitBoundsForSelected(padding: 60);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  void attachMap(GoogleMapController controller) {
    mapController = controller;
  }

  void selectRoute(int routeIndex) {
    state = state.copyWith(selectedIndex: routeIndex);
    _fitBoundsForSelected(padding: 60);
  }

  Future<void> _fitBoundsForSelected({double padding = 50}) async {
    final controller = mapController;
    if (controller == null) return;
    final selectedIdx = state.selectedIndex;
    if (selectedIdx == null) return;

    final ro = state.routes.firstWhere((r) => r.index == selectedIdx, orElse: () => state.routes.first);
    final sw = LatLng(ro.bounds.southwest.lat, ro.bounds.southwest.lng);
    final ne = LatLng(ro.bounds.northeast.lat, ro.bounds.northeast.lng);
    await Future.delayed(const Duration(milliseconds: 150));
    await controller.animateCamera(CameraUpdate.newLatLngBounds(LatLngBounds(southwest: sw, northeast: ne), padding));
  }
}