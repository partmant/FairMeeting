import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fair_front/controllers/user_controller.dart';
import 'package:fair_front/buttons/friendslist_button.dart';
import 'package:fair_front/buttons/info_menu_button.dart';
import 'package:fair_front/widgets/user_info_box.dart';
import 'package:fair_front/widgets/info_appbar.dart';
import 'package:fair_front/widgets/confirm_dialog.dart';

class MyInfoPage extends StatelessWidget {
  const MyInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const InfoAppBar(title: '내 정보'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            // 사용자 정보 박스 위젯
            UserInfoBox(
              userName: userController.userName,
              profileImageUrl: userController.profileImageUrl,
            ),

            const SizedBox(height: 20),

            // 친구 목록 보기 버튼 (위젯으로 분리됨)
            const FriendsListButton(),

            const SizedBox(height: 30),

            // 메뉴 리스트
            SizedBox(
              height: 325,
              child: Container(
                padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    InfoMenuButton(
                      icon: Icons.lock,
                      title: '개인 정보 및 보안',
                      onPressed: () {
                        print("개인 정보 및 보안 클릭, 유저 ID: ${userController.userId}");
                      },
                    ),
                    InfoMenuButton(
                      icon: Icons.campaign,
                      title: '공지사항',
                      onPressed: () {
                        print("공지사항 클릭");
                      },
                    ),
                    InfoMenuButton(
                      icon: Icons.policy,
                      title: '약관 및 정책',
                      onPressed: () {
                        print("약관 및 정책 클릭");
                      },
                    ),
                    InfoMenuButton(
                      icon: Icons.logout,
                      title: '로그아웃',
                      onPressed: () {
                        DialogService.showConfirmDialog(
                          context: context,
                          title: '로그아웃',
                          message: '로그아웃하시겠습니까?',
                          confirmLabel: '확인',
                          onConfirm: () {
                            final userController =
                                context.read<UserController>();
                            userController.setGuest();
                            Navigator.of(context).pop();
                          },
                        );
                      },
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
