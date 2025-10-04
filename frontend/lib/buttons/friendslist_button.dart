import 'package:flutter/material.dart';
import 'package:fair_front/services/get_friends_list_service.dart';

class FriendsListButton extends StatelessWidget {
  const FriendsListButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, right: 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: () => GetFriendsListService.showFriendsDialog(context),
              icon: const Icon(Icons.people, color: Colors.black, size: 16),
              label: const Text(
                '친구 목록 보기',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minimumSize: Size.zero,
              ),
            ),
            Container(
              height: 1.5,
              width: 115,
              color: const Color(0xFFD9C189),
            ),
          ],
        ),
      ),
    );
  }
}
