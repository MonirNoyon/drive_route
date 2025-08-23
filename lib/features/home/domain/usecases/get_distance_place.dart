import '../repositories/location_repository.dart';

class GetDistanceToPlace {
  final LocationRepository repo;
  GetDistanceToPlace(this.repo);

  Future<double> call(double lat, double lng) {
    return repo.getDistanceTo(lat, lng);
  }
}