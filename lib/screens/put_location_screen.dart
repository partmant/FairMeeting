import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fair_front/widgets/common_appbar.dart';
import 'package:fair_front/widgets/put_location/location_list.dart';
import 'package:fair_front/widgets/put_location/location_button.dart';
import 'package:fair_front/widgets/put_location/fair_meeting_button.dart';
import 'package:fair_front/widgets/kakao_map.dart';
import 'package:fair_front/controllers/map_controller.dart';
import '../screens/main_menu_screen.dart';

class PutLocationScreen extends StatelessWidget {
  const PutLocationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mapController = Provider.of<MapController>(context);
    final mapWidth = MediaQuery.of(context).size.width - 20;
    const sidePadding = 10.0;

    return WillPopScope(
      onWillPop: () async {
        // 앱바 뒤로가기와 동일한 동작: MainmenuScreen 으로 교체
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            settings: const RouteSettings(name: '/main-menu'),
            pageBuilder: (_, __, ___) => const MainmenuScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: common_appbar(context, title: '위치 입력하기'),
        body: Column(
          children: [
            const SizedBox(height: sidePadding),
            SizedBox(
              width: mapWidth,
              height: mapWidth,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: KakaoMapScreen(),
              ),
            ),
            FractionallySizedBox(
              widthFactor: 0.95,
              child: LocationButton(controller: mapController),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: LocationList(controller: mapController),
              ),
            ),
            const FairMeetingButton(),
          ],
        ),
      ),
    );
  }
}
