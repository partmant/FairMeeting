import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fair_front/controllers/user_controller.dart';
import 'package:fair_front/services/kakao_login_service.dart';
import 'package:fair_front/screens/main_menu_screen.dart';
import 'package:fair_front/widgets/loading_dialog.dart';

// 카카오톡 로그인 버튼 위젯 : StatefulWidget으로 구현
// 클릭 시 로딩 다이얼로그를 띄우고, 로그인/등록 작업 후 자동으로 다이얼로그를 닫고 화면 전환
class KakaoLoginButton extends StatefulWidget {
  const KakaoLoginButton({super.key});

  @override
  State<KakaoLoginButton> createState() => _KakaoLoginButtonState();
}

class _KakaoLoginButtonState extends State<KakaoLoginButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final userCtrl = context.read<UserController>();

    return GestureDetector(
      onTap: _isLoading ? null : () async {
        // 이미 로딩 중이면 추가 클릭 무시
        if (_isLoading) return;
        setState(() {
          _isLoading = true;
        });

        // 로딩 다이얼로그 띄우기
        showLoadingDialog(context);

        try {
          // 카카오톡 로그인 + 서버 회원 등록(또는 업데이트)
          final user = await KakaoLoginService.loginAndRegister();

          // 로컬 상태 업데이트
          userCtrl.setLoggedIn(
            userId: user.kakaoId,
            name: user.nickname,
            profileUrl: user.profileImageUrl,
          );

          // 다이얼로그 닫기
          hideLoadingDialog(context);

          // 화면 전환 (위젯이 여전히 마운트된 상태인지 확인)
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainmenuScreen()),
          );
        } catch (e) {
          // 예외 발생 시 다이얼로그를 닫고 에러 메시지 출력
          hideLoadingDialog(context);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('로그인 중 오류가 발생했습니다.')),
            );
          }
        } finally {
          // 로딩 상태 해제
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      },
      child: Container(
        height: 50,
        margin: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
          // 버튼 내부에도 작은 인디케이터를 표시하여 추가 피드백 제공
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Color(0xFFD9C189),
              strokeWidth: 2,
            ),
          )
              : const Text(
            '카카오톡으로 로그인',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
