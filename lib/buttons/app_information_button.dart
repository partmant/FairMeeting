import 'package:flutter/material.dart';

class FairMeetingInfoScreen extends StatelessWidget {
  const FairMeetingInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        title: Padding(
          padding: const EdgeInsets.only(top: 25), // 상하 위치 조정
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.black,
                size: 28, // 아이콘 크기
              ),
              SizedBox(width: 8),
              Text(
                'FAIR-MEETING 정보',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25, // 텍스트 크기
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [SizedBox(width: 48)],
      ),

      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 90),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 380,
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFD9C189), width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FAIR-MEETING이란?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '- 이동 경로 기반 최적의 약속 장소 추천 서비스',
                    style: TextStyle(
                      color: Color(0xFFD9C189),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '주요 기능',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text('- 중간 지점 찾기',
                      style: TextStyle(color: Colors.grey)),
                  Text('- 추천 장소 추천',
                      style: TextStyle(color: Colors.grey)),
                  Text('- 앱 및 웹 지원',
                      style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 20),
                  Text(
                    '사용법 가이드',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text('step 1 : 사용자의 위치 입력'),
                  Text('step 2 : 입력 후 Fair Meeting ! 버튼 클릭'),
                  Text('step 3 : 위치의 중간 지점 생성 후 길 안내'),
                  Text('step 4 : 만남 성공 !!'),
                ],
              ),
            ),
          ),
          Spacer(),
          Center(
            child: Column(
              children: [
                Text(
                  '버전 정보',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'v1.28.0',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD9C189),
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 50),
              ],
            ),
          )
        ],
      ),
    );
  }
}