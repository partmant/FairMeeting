import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_config.dart'; // ✅ 추가된 경로
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SearchAddressScreen extends StatefulWidget {
  const SearchAddressScreen({Key? key}) : super(key: key);

  @override
  State<SearchAddressScreen> createState() => _SearchAddressScreenState();
}

class _SearchAddressScreenState extends State<SearchAddressScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _suggestions = [];
  bool _isLoading = false;

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

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/address-autocomplete')
        .replace(queryParameters: {
      'query': query,
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
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
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "주소 입력",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            if (_isLoading) const LinearProgressIndicator(),
            const SizedBox(height: 10),
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
                      Navigator.pop(context, suggestion);
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
