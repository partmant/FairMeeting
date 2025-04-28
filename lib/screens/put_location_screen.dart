// put_location_screen.dart (화면 전체를 구성하는 파일)
import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:fair_front/widgets/go_back.dart';
import 'package:fair_front/screens/search_address_screen.dart';
import 'package:fair_front/widgets/put_location/location_map.dart';
import 'package:fair_front/widgets/put_location/location_list.dart';
import 'package:fair_front/widgets/put_location/location_button.dart';
import 'package:fair_front/controllers/location_controller.dart';

class PutLocationScreen extends StatefulWidget {
  const PutLocationScreen({super.key});

  @override
  State<PutLocationScreen> createState() => _PutLocationScreenState();
}

class _PutLocationScreenState extends State<PutLocationScreen> {
  final LocationController _controller = LocationController();

  @override
  void initState() {
    super.initState();
    _controller.onChanged = () {
      if (mounted) setState(() {});
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double mapWidth = MediaQuery.of(context).size.width - 20;
    const double sidePadding = 10;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildCommonAppBar(context, title: '위치 입력하기'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: sidePadding),
            LocationMap(  // 지도
              controller: _controller,
              width: mapWidth,
              height: mapWidth,
            ),
            const SizedBox(height: sidePadding),
            LocationButton(controller: _controller),  // 위치 입력하기 버튼
            const SizedBox(height: 10),
            LocationList(controller: _controller),  // 선택된 주소 리스트
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: sidePadding),
              child: Divider(color: Colors.black26, thickness: 1),
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
                  foregroundColor: const Color(0xFFD9C189),
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
