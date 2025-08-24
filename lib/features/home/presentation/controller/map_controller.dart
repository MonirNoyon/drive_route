import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../home/domain/entities/location_entity.dart';
import '../../../home/domain/usecases/get_current_location.dart';
import '../../../home/domain/usecases/watch_location_stream.dart';

class MapState {
  final bool loading;
  final LatLng? myLatLng;
  final double? accuracy;
  final String? error;

  const MapState({
    required this.loading,
    this.myLatLng,
    this.accuracy,
    this.error,
  });

  MapState copyWith({
    bool? loading,
    LatLng? myLatLng,
    double? accuracy,
    String? error,
  }) =>
      MapState(
        loading: loading ?? this.loading,
        myLatLng: myLatLng ?? this.myLatLng,
        accuracy: accuracy ?? this.accuracy,
        error: error,
      );

  factory MapState.initial() => const MapState(loading: true);
}

class MapController extends StateNotifier<MapState> {
  final GetCurrentLocation getCurrent;
  final WatchLocationStream watchLocation;
  StreamSubscription<LocationEntity>? _sub;

  MapController({required this.getCurrent, required this.watchLocation})
      : super(MapState.initial());

  Future<void> init() async {
    try {
      final first = await getCurrent();
      state = state.copyWith(
        loading: false,
        myLatLng: first.latLng,
        accuracy: first.accuracyMeters,
      );
      _sub = watchLocation().listen((loc) {
        state = state.copyWith(
          myLatLng: loc.latLng,
          accuracy: loc.accuracyMeters,
        );
      });
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}