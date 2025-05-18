import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_talk/kakao_flutter_sdk_talk.dart';

class GetFriendsListService {
  /// 친구 목록 가져오기
  static Future<List<Friend>> fetchFriends() async {
    try {
      final friends = await TalkApi.instance.friends();
      return friends.elements ?? [];
    } catch (e) {
      print('친구 목록 불러오기 실패: $e');
      rethrow;
    }
  }

  /// 친구 목록 다이얼로그 표시
  static Future<void> showFriendsDialog(BuildContext context) async {
    try {
      final friends = await fetchFriends();

      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('친구 목록', style: TextStyle(color: Colors.black)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                final name = friend.profileNickname ?? '이름 없음';
                final profileUrl = friend.profileThumbnailImage ?? '';

                return ListTile(
                  leading: profileUrl.isNotEmpty
                      ? CircleAvatar(backgroundImage: NetworkImage(profileUrl))
                      : const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(name, style: const TextStyle(color: Colors.black)),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('닫기', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('친구 목록을 불러오지 못했습니다.')),
        );
      }
    }
  }
}