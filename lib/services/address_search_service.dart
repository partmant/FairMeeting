import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';

class AddressSearchService {
  static Future<List<dynamic>> fetchSuggestions(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/address-autocomplete')
        .replace(queryParameters: {'query': query});

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data as List<dynamic>;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
