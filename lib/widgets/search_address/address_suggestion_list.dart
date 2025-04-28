import 'package:flutter/material.dart';

// search_address의 하단 자동완성 주소 리스트
class AddressSuggestionList extends StatelessWidget {
  final List<dynamic> suggestions;
  final Function(Map<String, dynamic>) onSelect;

  const AddressSuggestionList({
    super.key,
    required this.suggestions,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index] as Map<String, dynamic>;
          final name = suggestion['name'] ?? '';
          return ListTile(
            leading: const Icon(Icons.location_on),
            title: Text(name),
            onTap: () => onSelect(suggestion),
          );
        },
      ),
    );
  }
}
