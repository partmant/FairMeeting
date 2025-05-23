import 'package:flutter/material.dart';

typedef OnCategoryTap = Future<void> Function(String code, bool nowOn);

class CategoryBar extends StatelessWidget {
  final OnCategoryTap onTap;
  final Map<String,bool> state; // {'FD6':false, 'CE7':true, ...}

  const CategoryBar({required this.onTap, required this.state, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    final items = [
      {'code':'CT1','label':'문화시설','icon':Icons.museum},
      {'code':'FD6','label':'음식점','icon':Icons.restaurant},
      {'code':'CE7','label':'카페','icon':Icons.local_cafe},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((it) {
          final code = it['code'] as String;
          final on   = state[code]!;
          return ChoiceChip(
            label: Text(
              it['label'] as String,
              style: TextStyle(
                color: on ? Colors.white : Colors.black87,
                fontWeight: on ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            avatar: Icon(
              it['icon'] as IconData,
              color: on ? Colors.white : Colors.grey,
            ),
            selected: on,
            onSelected: (_) => onTap(code, on),
            selectedColor: const Color(0xFFD9C189),
            backgroundColor: Colors.grey.shade200,
          );
        }).toList(),
      ),
    );
  }
}