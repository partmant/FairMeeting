import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fair_front/widgets/go_back.dart';
import 'package:fair_front/widgets/put_location/location_map.dart';
import 'package:fair_front/widgets/put_location/location_list.dart';
import 'package:fair_front/widgets/put_location/location_button.dart';
import 'package:fair_front/controllers/location_controller.dart';

class PutLocationScreen extends StatelessWidget {
  const PutLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locationController = Provider.of<LocationController>(context); // Provider로부터 컨트롤러 가져오기
    double mapWidth = MediaQuery.of(context).size.width - 20;
    const double sidePadding = 10;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildCommonAppBar(context, title: '위치 입력하기'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: sidePadding),
            LocationMap(  // 지도 생성
              controller: locationController,
              width: mapWidth,
              height: mapWidth,
            ),
            const SizedBox(height: sidePadding),
            LocationButton(controller: locationController),
            const SizedBox(height: 10),
            LocationList(controller: locationController),
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
