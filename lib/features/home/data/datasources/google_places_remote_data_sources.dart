import 'dart:convert';
import 'dart:io';
import 'package:car_routing_application/config/api_client/model/common_response.dart';
import 'package:car_routing_application/config/api_client/update_api_client.dart';
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
  ApiClient apiClient;
  GooglePlacesRemoteDataSourceImpl(this.apiClient);

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
  Future<PlaceDetailsModel> fetchPlaceDetails(
      String placeId, {
        String? sessionToken,
      }) async {
    // final params = <String, String>{
    //   'place_id': placeId,
    //   'key': _key,
    //   'fields': 'place_id,name,geometry/location',
    //   if (sessionToken != null) 'sessiontoken': sessionToken,
    // };
    //
    // final uri = Uri.https(
    //   'maps.googleapis.com',
    //   '/maps/api/place/details/json',
    //   params,
    // );
    //
    // try {
    //   final res = await client.get(uri);
    //   if (res.statusCode < 200 || res.statusCode >= 300) {
    //     throw HttpException('HTTP ${res.statusCode}');
    //   }
    //   final jsonMap = json.decode(res.body) as Map<String, dynamic>;
    //   final status = jsonMap['status'] as String?;
    //   if (status == 'OK') {
    //     return PlaceDetailsModel.fromJson(jsonMap);
    //   }
    //   throw StateError('Place Details error: $status');
    // } on SocketException {
    //   rethrow;
    // }
    return PlaceDetailsModel(placeId: '', name: '', lat: 0, lng: 0);
  }
}