import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';

class AddressService {
  static Future<String> fetchAddressName(double lat, double lng) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/address-name').replace(queryParameters: {
      'lat': lat.toString(),
      'lng': lng.toString(),
    });

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return json['name'] ?? "주소 없음";
    } else {
      throw Exception("주소 조회 실패: ${response.statusCode}");
    }
  }

  static Future<List<dynamic>> fetchAddressSuggestions(String query) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/address-autocomplete').replace(queryParameters: {
      'query': query,
    });

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    } else {
      throw Exception("자동완성 실패: ${response.statusCode}");
    }
  }
}
