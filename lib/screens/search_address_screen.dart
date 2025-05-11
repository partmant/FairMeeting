// screens/search_address_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/address_service.dart';
import '../models/place_autocomplete_response.dart';
import '../widgets/search_address/address_suggestion_list.dart';

class SearchAddressScreen extends StatefulWidget {
  const SearchAddressScreen({Key? key}) : super(key: key);

  @override
  State<SearchAddressScreen> createState() => _SearchAddressScreenState();
}

class _SearchAddressScreenState extends State<SearchAddressScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<PlaceAutoCompleteResponse> _suggestions = [];
  bool _isLoading = false;

  Future<void> _searchAddress(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final results = await AddressService.fetchAddressSuggestions(query);
      setState(() {
        _suggestions = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // 에러 핸들링 (optional)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('주소 검색 실패: $e')),
      );
    }
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
            AddressSuggestionList(  // 하단 주소 리스트
              suggestions: _suggestions,
              onSelect: (selected) {
                Navigator.pop(context, selected);
              },
            ),
          ],
        ),
      ),
    );
  }
}
