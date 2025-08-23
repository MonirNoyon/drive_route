import 'dart:convert';
import 'dart:io';
import 'package:car_routing_application/features/home/data/model/place_details_model.dart';
import 'package:car_routing_application/features/home/data/model/place_suggestion_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


abstract class GooglePlacesRemoteDataSource {
  Future<List<PlaceSuggestionModel>> fetchSuggestions(
      String input, {
        String? sessionToken,
        String? countryComponent,
      });

  Future<PlaceDetailsModel> fetchPlaceDetails(
      String placeId, {
        String? sessionToken,
      });
}

class GooglePlacesRemoteDataSourceImpl implements GooglePlacesRemoteDataSource {
  final http.Client client;
  GooglePlacesRemoteDataSourceImpl(this.client);

  String get _key {
    final k = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (k == null || k.isEmpty) {
      throw StateError('GOOGLE_MAPS_API_KEY not found in .env');
    }
    return k;
  }

  @override
  Future<List<PlaceSuggestionModel>> fetchSuggestions(
      String input, {
        String? sessionToken,
        String? countryComponent,
      }) async {
    final params = <String, String>{
      'input': input,
      'key': _key,
      if (sessionToken != null) 'sessiontoken': sessionToken,
      if (countryComponent != null) 'components': countryComponent,
    };

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      params,
    );

    try {
      final res = await client.get(uri);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw HttpException('HTTP ${res.statusCode}');
      }
      final jsonMap = json.decode(res.body) as Map<String, dynamic>;
      final status = jsonMap['status'] as String?;
      if (status == 'OK') {
        final list = (jsonMap['predictions'] as List).cast<Map<String, dynamic>>();
        return list.map((e) => PlaceSuggestionModel.fromJson(e)).toList();
      }
      throw StateError('Places Autocomplete error: $status');
    } on SocketException {
      rethrow;
    }
  }

  @override
  Future<PlaceDetailsModel> fetchPlaceDetails(
      String placeId, {
        String? sessionToken,
      }) async {
    final params = <String, String>{
      'place_id': placeId,
      'key': _key,
      'fields': 'place_id,name,geometry/location',
      if (sessionToken != null) 'sessiontoken': sessionToken,
    };

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/details/json',
      params,
    );

    try {
      final res = await client.get(uri);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw HttpException('HTTP ${res.statusCode}');
      }
      final jsonMap = json.decode(res.body) as Map<String, dynamic>;
      final status = jsonMap['status'] as String?;
      if (status == 'OK') {
        return PlaceDetailsModel.fromJson(jsonMap);
      }
      throw StateError('Place Details error: $status');
    } on SocketException {
      rethrow;
    }
  }
}