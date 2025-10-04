import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fair_front/widgets/common_appbar.dart';
import 'package:fair_front/widgets/put_location/location_list.dart';
import 'package:fair_front/widgets/put_location/fair_meeting_button.dart';
import 'package:fair_front/widgets/kakao_map.dart';
import 'package:fair_front/controllers/map_controller.dart';
import 'package:fair_front/widgets/put_location/location_button.dart';

class PutLocationScreen extends StatelessWidget {
  const PutLocationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mapController = Provider.of<MapController>(context);
    final mapWidth = MediaQuery.of(context).size.width - 20;
    const sidePadding = 10.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: common_appbar(context, title: '위치 입력하기'),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: sidePadding),
            // 지도
            SizedBox(
              width: mapWidth,
              height: mapWidth,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: KakaoMapScreen(),
              ),
            ),
            // const SizedBox(height: 8),
            // 초기화 버튼 (기존 LocationButton 재사용)
            FractionallySizedBox(
              widthFactor: 0.95,
              child: LocationButton(
                controller: mapController,
                showReset: true,
                showAdd: false,
              ),
            ),
            // const SizedBox(height: 8),

            // 주소 리스트 및 위치 입력 버튼
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: sidePadding),
                child: LocationList(controller: mapController),
              ),
            ),
            // 확인 버튼
            FairMeetingButton(),
          ],
        ),
      ),
    );
  }
}