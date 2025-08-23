import 'package:car_routing_application/features/home/data/datasources/google_places_remote_data_sources.dart';
import 'package:car_routing_application/features/home/data/repositories/location_repository_implementer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;


import '../domain/repositories/location_repository.dart';


final httpClientProvider = Provider<http.Client>((ref) => http.Client());


final googlePlacesRemoteDataSourceProvider =
Provider<GooglePlacesRemoteDataSource>((ref) {
  final client = ref.watch(httpClientProvider);
  return GooglePlacesRemoteDataSourceImpl(client);
});


final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  final remote = ref.watch(googlePlacesRemoteDataSourceProvider);
  return LocationRepositoryImpl(remote: remote);
});