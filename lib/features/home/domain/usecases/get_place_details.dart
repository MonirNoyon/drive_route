import 'package:car_routing_application/features/home/domain/entities/place_details.dart';
import 'package:car_routing_application/features/home/domain/repositories/location_repository.dart';

class GetPlaceDetails {
  final LocationRepository repo;
  GetPlaceDetails(this.repo);

  Future<PlaceDetails?> call(String placeId, {String? sessionToken}) {
    return repo.getPlaceDetails(placeId, sessionToken: sessionToken);
  }
}