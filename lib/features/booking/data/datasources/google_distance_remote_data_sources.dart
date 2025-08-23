import 'package:car_routing_application/config/api_client/model/common_response.dart';
import 'package:car_routing_application/config/api_client/update_api_client.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class DirectionsRemoteDataSource {
  Future<Map<String, dynamic>> fetchRoutesJson({
    required LatLng origin,
    required LatLng destination,
  });
}

class DirectionsRemoteDataSourceImpl implements DirectionsRemoteDataSource {
  final ApiClient client;
  DirectionsRemoteDataSourceImpl(this.client);

  String get _key {
    final k = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (k == null || k.isEmpty) {
      throw StateError('GOOGLE_MAPS_API_KEY not found in .env');
    }
    return k;
  }

  @override
  Future<Map<String, dynamic>> fetchRoutesJson({
    required LatLng origin,
    required LatLng destination,
  }) async {
    Map<String,dynamic> results = {};

    final params = {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'mode': 'driving',
      'alternatives': 'true',
      'key': _key,
    };

    final response = await client.handleRequest<Map<String,dynamic>>(
      method: RequestType.GET,
      endPoint: 'https://maps.googleapis.com/maps/api/directions/json',
      isCustomUrl: true,
      queryParams: params,
      fromJson: null,
    );

    response.fold(
          (error) {
        throw StateError('Place Suggestions error:');
      },
          (data) {
        results = data;
      },
    );
    return results;
  }
}