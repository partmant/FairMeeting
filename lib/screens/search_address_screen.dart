import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';
import '../widgets/search_address/address_suggestion_list.dart';
import '../services/address_search_service.dart';

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
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoading = true);

    final results = await AddressSearchService.fetchSuggestions(query);
    setState(() {
      _suggestions = results;
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
      appBar: AppBar(title: const Text("주소 검색")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 입력창 + 로딩 바 포함
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

            // 하단 주소 리스트
            AddressSuggestionList(
              suggestions: _suggestions,
              onSelect: (suggestion) {
                Navigator.pop(context, suggestion);
              },
            ),
          ],
        ),
      ),
    );
  }
}
