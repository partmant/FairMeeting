import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:fair_front/models/user_dto.dart';
import 'package:fair_front/services/user_service.dart';

/// 카카오 로그인부터 서버 회원등록까지 한 번에 처리하는 서비스
class KakaoLoginService {
  /// 카카오톡/웹 로그인 → 사용자 정보 조회 → 서버 등록 → UserDto 반환
  static Future<UserDto> loginAndRegister() async {
    // 1) 로그인 토큰 획득
    OAuthToken token;
    final installed = await isKakaoTalkInstalled();
    if (installed) {
      try {
        token = await UserApi.instance.loginWithKakaoTalk();
      } catch (_) {
        token = await UserApi.instance.loginWithKakaoAccount();
      }
    } else {
      token = await UserApi.instance.loginWithKakaoAccount();
    }

    // 2) 토큰이 없으면 예외
    if (token.accessToken.isEmpty) {
      throw Exception('카카오 로그인에 실패했습니다.');
    }

    // 3) 사용자 정보 요청
    final kakaoUser = await UserApi.instance.me();
    final dto = UserDto(
      kakaoId: kakaoUser.id.toString(),
      nickname: kakaoUser.kakaoAccount?.profile?.nickname    ?? '사용자',
      profileImageUrl: kakaoUser.kakaoAccount?.profile?.profileImageUrl ?? '',
    );

    // 4) 서버에 회원 등록
    await UserService.registerUser(dto);

    return dto;
  }
}
