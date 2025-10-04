import 'package:url_launcher/url_launcher.dart';

// 외부 브라우저에서 네이버 길찾기로 연결하기
// 카카오톡지도는 지원 X
Future<void> openNaverWebRoute({
  required String sName,
  required double sLat,
  required double sLng,
  required String dName,
  required double dLat,
  required double dLng,
}) async {
  final uri = Uri.parse(
    'https://m.map.naver.com/route.nhn'
        '?menu=route'
        '&sname=${Uri.encodeComponent(sName)}'
        '&sx=$sLng&sy=$sLat'          // Naver: x=경도, y=위도
        '&ename=${Uri.encodeComponent(dName)}'
        '&ex=$dLng&ey=$dLat'
        '&pathType=1'                 // 1 = 대중교통
        '&showMap=true',
  );

  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw '길찾기 페이지를 열 수 없습니다: $uri';
  }
}

// 공유용 네이버 지도 링크 생성 함수
// 캘린더에 들어가는 목적지가 좌표값이 같이 전달될 경우, 네이버 길찾기에 목적지만 넣어서 사용
String generateNaverMapLink({
  required String placeName,
  required double lat,
  required double lng,
}) {
  return 'https://map.naver.com/v5/directions?en=$lng,$lat&place=${Uri.encodeComponent(placeName)}&pathType=0';
}