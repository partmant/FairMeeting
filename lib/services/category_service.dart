import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';
import '../models/category_response.dart';

class CategoryService {
  /// 카테고리 코드 (예: 'FD6', 'CE7', 'CT1')
  static Future<List<CategoryResponse>> fetchByCategory({
    required String categoryCode,
    required double lon,
    required double lat,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/category/search').replace(
      queryParameters: {
        'categoryCode': categoryCode,
        'x': lon.toString(),
        'y': lat.toString(),
      },
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList
          .map((item) => CategoryResponse.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('카테고리 조회 실패: ${response.statusCode}');
    }
  }
}