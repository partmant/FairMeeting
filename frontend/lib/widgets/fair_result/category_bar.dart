import 'package:flutter/material.dart';

typedef OnCategoryTap = Future<void> Function(String code, bool nowOn);

class CategoryBar extends StatelessWidget {
  final OnCategoryTap onTap;
  final Map<String,bool> state; // {'FD6':false, 'CE7':true, ...}

  const CategoryBar({
    required this.onTap,
    required this.state,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    final items = [
      {'code':'CT1','label':'문화시설','icon':Icons.museum},
      {'code':'FD6','label':'음식점','icon':Icons.restaurant},
      {'code':'CE7','label':'카페','icon':Icons.local_cafe},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: items.map((it) {
            final code = it['code'] as String;
            final on   = state[code]!;
            return Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: ChoiceChip(
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
                  size: 20,
                ),
                selected: on,
                onSelected: (_) => onTap(code, on),
                selectedColor: const Color(0xFFD9C189),
                backgroundColor: Colors.grey.shade200,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, // 내부 좌우 패딩
                  vertical: 6,    // 내부 상하 패딩 (세로 크기 축소)
                ),
                labelStyle: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
