import 'dart:convert';
import 'dart:io'; // 추가: 플랫폼 체크를 위해
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fair_front/widgets/go_back.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '주소 자동완성',
      debugShowCheckedModeBanner: false,
      home: const AddressAutoCompleteScreen(),
    );
  }
}

class AddressAutoCompleteScreen extends StatefulWidget {
  const AddressAutoCompleteScreen({Key? key}) : super(key: key);

  @override
  State<AddressAutoCompleteScreen> createState() =>
      _AddressAutoCompleteScreenState();
}

class _AddressAutoCompleteScreenState extends State<AddressAutoCompleteScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _suggestions = [];
  bool _isLoading = false;

  // 개발 환경: Android 에뮬레이터의 경우, PC의 localhost를 가리키는 주소입니다.
  // 실제 기기 테스트 시 PC의 IP 주소나 ngrok URL 등을 사용해야 합니다.

  // 수정된 부분 시작 - 플랫폼 구분하여 URL 설정
  final String backendUrl = Platform.isAndroid
      ? 'http://10.0.2.2:8088/api/address-autocomplete' // Android용
      : 'http://127.0.0.1:8088/api/address-autocomplete'; // iOS 시뮬레이터용
  // 수정된 부분 끝

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
        final data = jsonDecode(utf8.decode(response.bodyBytes)); // UTF-8로 디코딩, 명시적으로 안 해주면 한글 깨짐
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
      appBar: buildCommonAppBar(context, title:'주소 입력하기'),
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
                      // 항목 선택 시 TextField에 주소를 확정하고, 자동완성 목록을 초기화합니다.
                      setState(() {
                        _searchController.text = name;
                        _suggestions = [];
                      });
                      // 선택한 결과를 이전 화면으로 반환하는 동작을 추가할 수도 있습니다.
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