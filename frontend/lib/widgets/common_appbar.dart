import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fair_front/screens/fair_result_screen.dart';
import 'package:fair_front/controllers/map_controller.dart';

/// 공통 AppBar
PreferredSizeWidget common_appbar(
    BuildContext context, {
      String? title,
      List<Widget>? extraActions,
    }) {
  final currentRoute = ModalRoute.of(context)?.settings.name;
  final mapController = Provider.of<MapController>(context, listen: false);

  // 뒤로가기 버튼
  final leading = IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.black),
    onPressed: () => Navigator.of(context).pop(),
  );

  // 화면별 Actions
  final actions = <Widget>[];

  // PutLocation → Result 버튼
  if (currentRoute == '/put-location' && mapController.hasLastResult) {
    actions.add(
      IconButton(
        icon: const Icon(Icons.arrow_forward, color: Colors.black),
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              settings: const RouteSettings(name: '/fair-result'),
              pageBuilder: (_, __, ___) => FairResultMapScreen(
                initialCenter: mapController.lastCenter!,
                initialResponse: mapController.lastFairLocationResponse!,
              ),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
      ),
    );
  }

  // extraActions 파라미터로 전달된 버튼들
  if (extraActions != null) {
    actions.addAll(extraActions);
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
