import '../../domain/entities/place_details.dart';

class PlaceDetailsModel extends PlaceDetails {
  const PlaceDetailsModel({
    required super.placeId,
    required super.name,
    required super.lat,
    required super.lng,
  });

  factory PlaceDetailsModel.fromJson(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>;
    final geometry = result['geometry'] as Map<String, dynamic>;
    final loc = geometry['location'] as Map<String, dynamic>;
    return PlaceDetailsModel(
      placeId: result['place_id'] as String,
      name: (result['name'] as String?) ?? '',
      lat: (loc['lat'] as num).toDouble(),
      lng: (loc['lng'] as num).toDouble(),
    );
  }
}