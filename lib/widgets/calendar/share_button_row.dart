import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:fair_front/services/kakao_share_service.dart';

class ShareButtonRow extends StatelessWidget {
  final Map<String, dynamic> selectedData;
  final DateTime selectedDay;
  final VoidCallback onEdit;
  final KakaoShareService kakaoShareService;

  const ShareButtonRow({
    super.key,
    required this.selectedData,
    required this.selectedDay,
    required this.onEdit,
    required this.kakaoShareService,
  });

  @override
  Widget build(BuildContext context) {
    // 선택된 약속 정보에서 시간·장소 추출
    final location = selectedData['location'] as String;
    final time = selectedData['time'] as String;
    final dateString = DateFormat('yyyy.MM.dd').format(selectedDay);

    return Row(
      children: [
        CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Text(
              '수정',
              style:
              TextStyle(color: Color(0xFFD9C189)),
            ),
            onPressed: onEdit
        ),
        const Spacer(),
        // 카카오톡 공유 버튼
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFD9C189),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(
                horizontal: 18, vertical: 10),
            onPressed: () async {
              final title = 'Fair Meeting 약속 알림 ($dateString)';
              final description = '장소: $location\n시간: $time';
              final baseUrl = dotenv.env['SERVER_BASE_URL']
                  ?? 'https://your.fallback.domain.com';
              // 실제 환경이라면: '$baseUrl/static/images/app_icon.jpg'
              final imageUrl =
                  'https://via.placeholder.com/300x150.png?text=FairMeeting';
              final linkUrl =
                  'https://m.map.naver.com/route.nhn?menu=route';
              debugPrint('[ShareButtonRow] linkUrl = $linkUrl');

              try {
                await kakaoShareService.shareFeedTemplate(
                  title: title,
                  description: description,
                  imageUrl: imageUrl,
                  linkUrl: linkUrl,
                );
              } catch (error) {
                debugPrint(
                    '카카오톡 공유 예외: $error');
              }
            },
            child: const Text(
              '공유',
              style:
              TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
