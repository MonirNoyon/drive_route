import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationEntity {
  final LatLng latLng;
  final double? accuracyMeters;
  const LocationEntity({required this.latLng, this.accuracyMeters});
}