import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchAddressScreen extends StatefulWidget {
  const SearchAddressScreen({Key? key}) : super(key: key);

  @override
  State<SearchAddressScreen> createState() => _SearchAddressScreenState();
}

class _SearchAddressScreenState extends State<SearchAddressScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _suggestions = [];
  bool _isLoading = false;

  // 개발 환경: Android 에뮬레이터의 경우, PC의 localhost를 가리키는 주소
  // 실제 기기 테스트 시 PC의 IP 주소 또는 ngrok URL 등을 사용
  final String backendUrl = 'http://10.0.2.2:8088/api/address-autocomplete';

  Future<void> _searchAddress(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final uri = Uri.parse(backendUrl).replace(queryParameters: {
      'query': query,
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        // UTF-8 디코딩하여 한글 깨짐 방지
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _suggestions = data as List<dynamic>;
        });
      } else {
        debugPrint("Backend API Error: ${response.statusCode}");
        setState(() {
          _suggestions = [];
        });
      }
    } catch (e) {
      debugPrint("Exception: $e");
      setState(() {
        _suggestions = [];
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _searchAddress(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("주소 자동완성"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 주소 입력 필드
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "주소 입력",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            // 로딩 인디케이터
            if (_isLoading) const LinearProgressIndicator(),
            const SizedBox(height: 10),
            // 자동완성 결과 목록 (장소 이름만 표시)
            Expanded(
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index] as Map<String, dynamic>;
                  final String name = suggestion['name'] ?? '';
                  return ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(name),
                    onTap: () {
                      setState(() {
                        Navigator.pop(context, suggestion); // 항목을 탭하면 선택한 결과를 반환하며 SearchAddressScreen 종료
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
