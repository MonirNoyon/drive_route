import 'dart:convert';
import 'dart:io';
import 'package:car_routing_application/config/api_client/model/common_response.dart';
import 'package:car_routing_application/config/api_client/update_api_client.dart';
import 'package:car_routing_application/features/home/data/model/place_details_model.dart';
import 'package:car_routing_application/features/home/data/model/place_suggestion_model.dart';
import 'package:car_routing_application/features/home/domain/entities/location_entity.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


abstract class GooglePlacesRemoteDataSource {
  Future<List<PlaceSuggestionModel>> fetchSuggestions(
      String input, {
        String? sessionToken,
        String? countryComponent,
      });

  Future<PlaceDetailsModel?> fetchPlaceDetails(
      String placeId, {
        String? sessionToken,
      });

  Future<LocationEntity> getCurrent();
  Stream<LocationEntity> watch();
}

class GooglePlacesRemoteDataSourceImpl implements GooglePlacesRemoteDataSource {
  ApiClient apiClient;
  GooglePlacesRemoteDataSourceImpl(this.apiClient);

  String get _key {
    final k = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (k == null || k.isEmpty) {
      throw StateError('GOOGLE_MAPS_API_KEY not found in .env');
    }
    return k;
  }

  Future<void> _ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission not granted');
    }
  }

  @override
  Future<List<PlaceSuggestionModel>> fetchSuggestions(
      String input, {
        String? sessionToken,
        String? countryComponent,
      }) async {

    List<PlaceSuggestionModel> suggestions = [];

    final params = <String, String>{
      'input': input,
      'key': _key,
      if (sessionToken != null) 'sessiontoken': sessionToken,
      if (countryComponent != null) 'components': countryComponent,
    };

    final response = await apiClient.handleRequest<Map>(
      method: RequestType.GET,
      endPoint: 'https://maps.googleapis.com/maps/api/place/autocomplete/json',
      isCustomUrl: true,
      queryParams: params,
      fromJson: null,
    );

    response.fold(
          (error) {
        throw StateError('Place Suggestions error:');
      },
          (data) {
          final predictions = data['predictions'] as List<dynamic>;
          suggestions = predictions
              .map((e) => PlaceSuggestionModel.fromJson(e as Map<String, dynamic>))
              .toList();
      },
    );
    return suggestions;
  }

  @override
  Future<PlaceDetailsModel?> fetchPlaceDetails(
      String placeId, {
        String? sessionToken,
      }) async {
    final params = <String, String>{
      'key': _key,
      'place_id': placeId,
    };
    PlaceDetailsModel? placeDetails;
    final response = await apiClient.handleRequest<Map>(
      method: RequestType.GET,
      endPoint: "https://maps.googleapis.com/maps/api/place/details/json",
      isCustomUrl: true,
      queryParams: params,
    );
    response.fold(
          (error) {
        throw StateError('Place Details error:');
      },
          (success) {
            if(success.containsKey('result') && success["result"].isNotEmpty){
              placeDetails =  PlaceDetailsModel(
                placeId: placeId.isNotEmpty ? placeId : success["result"]["place_id"],
                name: success["result"]["formatted_address"],
                lat: success["result"]["geometry"]?["location"]?["lat"],
                lng: success["result"]["geometry"]?["location"]?["lng"],
              );
            }
      },
    );
    return placeDetails;
  }

  @override
  Future<LocationEntity> getCurrent() async{
    await _ensurePermission();
    final pos = await Geolocator.getCurrentPosition();
    return LocationEntity(
      latLng: LatLng(pos.latitude, pos.longitude),
      accuracyMeters: pos.accuracy,
    );
  }

  @override
  Stream<LocationEntity> watch() async* {
    await _ensurePermission();
    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5, // meters
      ),
    ).map((pos) => LocationEntity(
      latLng: LatLng(pos.latitude, pos.longitude),
      accuracyMeters: pos.accuracy,
    ));
  }
}