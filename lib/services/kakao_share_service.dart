import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'package:kakao_flutter_sdk_template/kakao_flutter_sdk_template.dart';
import 'package:url_launcher/url_launcher.dart';

class KakaoShareService {
  // 카카오톡 공유 가능 여부 체크
  Future<bool> isKakaoInstallable() async {
    try {
      final available = await ShareClient.instance.isKakaoTalkSharingAvailable();
      return available;
    } catch (error) {
      debugPrint('카카오톡 공유 가능 여부 확인 중 오류: $error');
      return false;
    }
  }

  // 기본 Feed 템플릿을 사용하여 카카오톡에 공유하기
  Future<void> shareFeedTemplate({
    required String title,
    required String description,
    required String imageUrl,
    required String linkUrl,
  }) async {
    // 공유 가능 여부 확인
    final kakaoAvailable = await isKakaoInstallable();
    if (!kakaoAvailable) {
      // 카카오톡이 설치되어 있지 않으면 시스템 공유 다이얼로그로 대체
      final fallbackText = '$title\n$linkUrl';
      await _fallbackShare(fallbackText);
      return;
    }

    // FeedTemplate 구성 : 실제 카카오톡으로 공유되는 내용
    final FeedTemplate feedTemplate = FeedTemplate(
      content: Content(
        title: title,
        description: description,
        imageUrl: Uri.parse(imageUrl),
        link: Link(
          webUrl: Uri.parse(linkUrl),
          mobileWebUrl: Uri.parse(linkUrl),
        ),
      ),
      // optional: 소셜 정보 (좋아요, 댓글, 공유 수 등) : 제거 가능
      social: Social(likeCount: 100, commentCount: 20, sharedCount: 5),
      // optional: CTA 버튼
      buttons: [
        Button(
          title: '웹으로 보기',
          link: Link(
            webUrl: Uri.parse(linkUrl),
            mobileWebUrl: Uri.parse(linkUrl),
          ),
        ),
      ],
    );

    try {
      // shareDefault 호출로 공유용 URI 생성
      final Uri shareUri = await ShareClient.instance.shareDefault(
        template: feedTemplate,
      );
      // 카카오톡 실행하여 공유
      await ShareClient.instance.launchKakaoTalk(shareUri);
      debugPrint('카카오톡 공유에 성공했습니다.');
    } catch (error) {
      debugPrint('카카오톡 공유 실패: $error');
    }
  }

  // 웹 페이지 스크랩(Scrap) 템플릿 공유
  // url : 공유할 페이지 URL : 도메인이 카카오 개발자 콘솔에 등록되어 있어야 함
  Future<void> shareScrapTemplate({required String url}) async {
    final kakaoAvailable = await isKakaoInstallable();
    if (!kakaoAvailable) {
      // 설치되어 있지 않으면 웹으로 대체
      final fallbackText = url;
      await _fallbackShare(fallbackText);
      return;
    }

    try {
      // 스크랩 템플릿으로 공유용 URI 생성
      final Uri shareUri = await ShareClient.instance.shareScrap(
        url: url,
      );
      // 카카오톡 실행하여 공유
      await ShareClient.instance.launchKakaoTalk(shareUri);
      debugPrint('카카오톡 스크랩 공유에 성공했습니다.');
    } catch (error) {
      debugPrint('카카오톡 스크랩 공유 실패: $error');
    }
  }

  // 카카오톡이 설치되어 있지 않거나 예외 발생 시, 시스템 공유 다이얼로그로 대체
  Future<void> _fallbackShare(String text) async {
    final uri = Uri.encodeFull('sms:?body=$text');
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      debugPrint('시스템 공유 다이얼로그 호출 실패');
    }
  }
}
