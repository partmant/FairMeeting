import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_talk/kakao_flutter_sdk_talk.dart';

class GetFriendsListService {
  static Future<List<Friend>> fetchFriends() async {
    try {
      final friends = await TalkApi.instance.friends();
      return friends.elements ?? [];
    } catch (e) {
      print('친구 목록 불러오기 실패: $e');
      return []; // 오류 발생 시 빈 리스트 반환
    }
  }

  static Future<void> showFriendsDialog(BuildContext context) async {
    try {
      final friends = await fetchFriends();

      if (!context.mounted) return;

      if (friends.isEmpty) {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 40),
            backgroundColor: Colors.white,
            child: SizedBox(
              width: 280,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '친구 목록',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '표시할 친구가 없습니다.',
                      style: TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Spacer(),
                        IntrinsicWidth(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('닫기', style: TextStyle(color: Colors.black)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          backgroundColor: Colors.white,
          child: SizedBox(
            width: 280,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '친구 목록',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 250, // 필요 시 더 크게 조절 가능
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Spacer(),
                      IntrinsicWidth(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('닫기', style: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('친구 목록을 불러오지 못했습니다.')),
        );
      }
    }
  }

}
