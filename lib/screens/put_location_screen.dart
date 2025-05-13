import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fair_front/widgets/go_back.dart';
import 'package:fair_front/widgets/put_location/location_map.dart';
import 'package:fair_front/widgets/put_location/location_list.dart';
import 'package:fair_front/widgets/put_location/location_button.dart';
import 'package:fair_front/widgets/put_location/fair_meeting_button.dart';
import 'package:fair_front/controllers/location_controller.dart';

class PutLocationScreen extends StatelessWidget {
  const PutLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locationController = Provider.of<LocationController>(context);
    double mapWidth = MediaQuery.of(context).size.width - 20;
    const double sidePadding = 10;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildCommonAppBar(context, title: '위치 입력하기'),
      body: Column(
        children: [
          const SizedBox(height: sidePadding),
          LocationMap(
            controller: locationController,
            width: mapWidth,
            height: mapWidth,
          ),
          const SizedBox(height: sidePadding),
          LocationButton(controller: locationController),
          Expanded(child: Padding(
            padding: const EdgeInsets.only(top: 12.0),  // 상하 여백
            child: LocationList(controller: locationController),
          ),
          ),
          const FairMeetingButton(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
