import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';
import '../models/geocoding_response.dart';
import '../models/place_autocomplete_response.dart';

class AddressService {
  static Future<GeocodingResponse> fetchAddressName(double lat, double lng) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/geocoding/address').replace(queryParameters: {
      'lat': lat.toString(),
      'lng': lng.toString(),
    });

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return GeocodingResponse.fromJson(json);
    } else {
      throw Exception("주소 조회 실패: ${response.statusCode}");
    }
  }

  static Future<List<PlaceAutoCompleteResponse>> fetchAddressSuggestions(String query) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/places/autocomplete').replace(queryParameters: {
      'query': query,
    });

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((item) => PlaceAutoCompleteResponse.fromJson(item)).toList();
    } else {
      throw Exception("자동완성 실패: ${response.statusCode}");
    }
  }
}
