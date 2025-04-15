import 'package:flutter/material.dart';
import '../widgets/logo_title.dart';

class AppStart extends StatefulWidget {
  const AppStart({super.key});

  @override
  State<AppStart> createState() => _AppStartState();
}

class _AppStartState extends State<AppStart> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/main');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea( // ✅ 상태바 영역 피하기
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // ✅ 가운데 정렬
            children: const [
              LogoTitle(),
            ],
          ),
        ),
      ),
    );
  }
}