import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:fair_front/widgets/go_back.dart';
import 'package:fair_front/screens/kakao_map_screen.dart';
import 'package:dotted_border/dotted_border.dart'; // 점선 테두리용

class PutLocationScreen extends StatefulWidget {
  const PutLocationScreen({super.key});

  @override
  State<PutLocationScreen> createState() => _PutLocationScreenState();
}

class _PutLocationScreenState extends State<PutLocationScreen> {
  KakaoMapController? mapController;

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double mapWidth = MediaQuery.of(context).size.width - 20; // 여백 10 양쪽
    const double sidePadding = 10;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildCommonAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: sidePadding),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: sidePadding),
              width: double.infinity,
              height: mapWidth, // 1:1 비율
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: KakaoMap(
                  onMapCreated: (controller) {
                    mapController = controller;
                  },
                ),
              ),
            ),
            const SizedBox(height: sidePadding),

            // 🔥 전체 삭제 텍스트
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    print('전체 삭제 버튼 클릭됨');
                  },
                  child: const Text(
                    '전체 삭제',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: sidePadding),


            // 위치 입력하기 버튼 (그림자 + 점선 테두리)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: sidePadding),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              child: DottedBorder(
                color: Colors.black,
                strokeWidth: 1.5,
                borderType: BorderType.RRect,
                radius: const Radius.circular(10),
                dashPattern: const [6, 4],
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const KakaoMapScreen()),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      '위치 입력하기',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 100), // 하단 버튼 공간 확보용
          ],
        ),
      ),

      // 🔥 하단 고정 "Fair Meeting !" 버튼 (테두리만 색 / 배경 투명)
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: sidePadding),
              child: Divider(
                color: Colors.black26,
                thickness: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: sidePadding, vertical: sidePadding),
              child: OutlinedButton(
                onPressed: () {
                  print('모임 장소 확정 버튼 눌림');
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD9C189), width: 2),
                  backgroundColor: Colors.transparent,
                  foregroundColor: Color(0xFFD9C189),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      'Fair Meeting !',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
