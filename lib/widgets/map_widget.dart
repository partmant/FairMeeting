import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String hashKey = (await KakaoMapSdk.instance.hashKey())!;
  debugPrint('해시키: $hashKey');

  await KakaoMapSdk.instance.initialize('9255023b3d9eebeecb1887c7ec03991d');

  runApp(const MaterialApp(
    home: KakaoMapExample(),
  ));
}

class KakaoMapExample extends StatelessWidget {
  const KakaoMapExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KakaoMap(
        option: const KakaoMapOption(
          position: LatLng(37.5665, 126.9780), // 서울 시청 위치
          zoomLevel: 3,
        ),
        onMapReady: (controller) {
          // 지도가 로딩되었을 때 호출됨
          debugPrint('카카오맵 로드 완료');
        },
        onMapError: (error) {
          debugPrint('지도 로딩 실패: $error');
        },
      ),
    );
  }
}
