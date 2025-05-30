import 'package:intl/intl.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'package:kakao_flutter_sdk_template/kakao_flutter_sdk_template.dart';

class KakaoShareService {
  /// 선택한 약속 정보를 카카오톡으로 공유합니다.
  /// [appointment]는 시간, 장소, id 등을 포함한 Map 혹은 Appointment 모델 객체입니다.
  static Future<void> shareAppointment(Map<String, dynamic> appointment, DateTime date) async {
    // 카카오톡 공유 가능 여부 체크
    final available = await ShareClient.instance.isKakaoTalkSharingAvailable();
    if (!available) {
      throw Exception('카카오톡이 설치되어 있지 않습니다.');
    }

    // 템플릿 구성
    final title = '약속 알림 (${DateFormat('yyyy.MM.dd').format(date)})';
    final description = '${appointment['time']}에 ${appointment['location']}에서 만나요!';
    final template = FeedTemplate(
      content: Content(
        title: title,
        description: description,
        imageUrl: Uri.parse('https://your.server.com/assets/meeting.png'),
        link: Link(
          mobileWebUrl: Uri.parse('https://your.app.com/appointments'),
          androidExecutionParams: {'id': appointment['id'].toString()},
          iosExecutionParams: {'id': appointment['id'].toString()},
        ),
      ),
      buttons: [
        Button(
          title: '앱에서 보기',
          link: Link(
            mobileWebUrl: Uri.parse('https://your.app.com/appointments/${appointment['id']}'),
          ),
        )
      ],
    );

    // 공유 URI 생성 및 카톡 실행
    final uri = await ShareClient.instance.shareDefault(template: template);
    await ShareClient.instance.launchKakaoTalk(uri);
  }
}
