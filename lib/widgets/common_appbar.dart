import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/main_menu_screen.dart';
import '../screens/put_location_screen.dart';
import '../screens/fair_result_screen.dart';
import '../controllers/map_controller.dart';

PreferredSizeWidget common_appbar(BuildContext context, {String? title}) {
  final currentRoute  = ModalRoute.of(context)?.settings.name;
  final mapController = Provider.of<MapController>(context, listen: false);

  // 뒤로가기 버튼
  final leading = IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.black),
    onPressed: () {
      if (currentRoute == '/put-location') {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            settings: const RouteSettings(name: '/main-menu'),
            pageBuilder: (_, __, ___) => const MainmenuScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      } else if (currentRoute == '/fair-result') {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            settings: const RouteSettings(name: '/put-location'),
            pageBuilder: (_, __, ___) => const PutLocationScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      } else {
        Navigator.pop(context);
      }
    },
  );

  // 앞으로 가기 버튼
  // put-location 화면에서 저장된 마지막 결과가 있을 때만
  final actions = <Widget>[];
  if (currentRoute == '/put-location' && mapController.hasLastResult) {
    actions.add(
      IconButton(
        icon: const Icon(Icons.arrow_forward, color: Colors.black),
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              settings: const RouteSettings(name: '/fair-result'),
              pageBuilder: (_, __, ___) => FairResultMapScreen(
                coordinates: mapController.lastCoordinates,
                center:      mapController.lastCenter,
              ),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
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
