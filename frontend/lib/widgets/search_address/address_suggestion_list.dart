import 'package:flutter/material.dart';
import '../../models/place_autocomplete_response.dart';

// 주소 자동완성 화면의 하단 주소 리스트
class AddressSuggestionList extends StatelessWidget {
  final List<PlaceAutoCompleteResponse> suggestions;
  final void Function(PlaceAutoCompleteResponse) onSelect;

  const AddressSuggestionList({
    Key? key,
    required this.suggestions,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return const Center(child: Text("검색 결과가 없습니다."));
    }

    // Expanded 제거
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          title: Text(suggestion.placeName),
          subtitle: Text(
            suggestion.roadAddress,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          onTap: () => onSelect(suggestion),
        );
      },
    );
  }
}
