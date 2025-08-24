import '../entities/location_entity.dart';
import '../repositories/location_repository.dart';

class WatchLocationStream {
  final LocationRepository repo;
  WatchLocationStream(this.repo);

  Stream<LocationEntity> call() => repo.watchLocation();
}