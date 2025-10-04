import 'package:flutter/material.dart';
import '../services/address_service.dart';
import '../models/place_autocomplete_response.dart';
import '../utils/keyboard_utils.dart';
import '../widgets/loading_dialog.dart';
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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
  }

  void _onSearchTextChanged() {
    _searchAddress(_searchController.text);
  }

  Future<void> _searchAddress(String query) async {
    if (query.trim().isEmpty) {
      if (!mounted) return;
      setState(() => _suggestions = []);
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final results = await AddressService.fetchAddressSuggestions(query);

      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 키보드 올라올 때 body 리사이즈 허용
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text("주소 검색")),
      body: SafeArea(
        child: Padding(
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
                child: AddressSuggestionList(
                  suggestions: _suggestions,
                    onSelect: (selected) async {
                      showLoadingDialog(context);
                      FocusScope.of(context).unfocus(); // 자판 내리기
                      await waitForKeyboardToDismiss(context); // 완전히 내려갈 때까지 대기
                      hideLoadingDialog(context);
                      Navigator.pop(context, selected);
                    },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
