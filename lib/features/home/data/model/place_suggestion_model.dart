import 'package:car_routing_application/features/home/domain/entities/place_suggestions.dart';

class PlaceSuggestionModel extends PlaceSuggestion {
  const PlaceSuggestionModel({
    required super.placeId,
    required super.description,
  });

  factory PlaceSuggestionModel.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestionModel(
      placeId: json['place_id'] as String,
      description: json['description'] as String,
    );
  }
}