import '../entities/location_entity.dart';
import '../repositories/location_repository.dart';

class GetCurrentLocation {
  final LocationRepository repo;
  GetCurrentLocation(this.repo);

  Future<LocationEntity> call() => repo.getCurrentLocation();
}