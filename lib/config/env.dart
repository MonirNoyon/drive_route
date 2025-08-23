import 'package:flutter_riverpod/flutter_riverpod.dart';

final googleApiKeyProvider = Provider<String>((ref) {
  const key = 'YOUR_GOOGLE_API_KEY';
  if (key == 'YOUR_GOOGLE_API_KEY') {
    throw StateError('Set Google API key in google_api_key_provider.dart');
  }
  return key;
});