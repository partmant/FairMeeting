import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fair_front/screens/fair_result_screen.dart';
import 'package:fair_front/controllers/map_controller.dart';

import '../screens/edit_result_screen.dart';

PreferredSizeWidget common_appbar(BuildContext context, {String? title}) {
  final currentRoute = ModalRoute.of(context)?.settings.name;
  final mapController = Provider.of<MapController>(context, listen: false);

  // 뒤로가기 버튼
  final leading = IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.black),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // 위치 입력 화면일 때 → 결과화면으로 가기 버튼
  final actions = <Widget>[];
  if (currentRoute == '/put-location' && mapController.hasLastResult) {
    actions.add(
      IconButton(
        icon: const Icon(Icons.arrow_forward, color: Colors.black),
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              settings: const RouteSettings(name: '/fair-result'),
              pageBuilder: (_, __, ___) =>
                  FairResultMapScreen(
                    center: mapController.lastCenter,
                    fairLocationResponse: mapController
                        .lastFairLocationResponse,
                  ),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
      ),
    );
  }

    // 결과 화면일 때 → 중간지점 수정 버튼
    if (currentRoute == '/fair-result') {
      actions.add(
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => EditResultScreen(
                  initialCenter: mapController.currentCenter,
                ),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          child: const Text('수정', style: TextStyle(color: Colors.black)),
        ),
      );
    }

  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    leading: leading,
    centerTitle: true,
    title: title != null
        ? Text(
      title,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    )
        : null,
    actions: actions,
  );
}
