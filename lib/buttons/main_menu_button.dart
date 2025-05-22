import 'package:flutter/material.dart';

class MainMenuButton extends StatelessWidget {
  final Map<String, dynamic> data;

  const MainMenuButton({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final Color textColor = data['textColor'] ?? Colors.white;
    final Color subTextColor = data['subTextColor'] ?? textColor;

    return ElevatedButton(
      onPressed: data['onTap'],
      style: ElevatedButton.styleFrom(
        backgroundColor: data['color'],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(12),
        elevation: 2,
      ),
      child: Stack(
        children: [
          // 아이콘 (좌상단)
          Positioned(
            top: 0,
            left: 0,
            child: Icon(
              data['icon'],
              color: textColor,
              size: 40,
              shadows: [
                Shadow(
                  offset: const Offset(1.5, 1.5),
                  blurRadius: 1,
                  color: Colors.black.withAlpha(51),
                ),
              ],
            ),
          ),

          // 중앙 텍스트
          Center(
            child: Text(
              data['label'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: textColor,
                shadows: [
                  Shadow(
                    offset: const Offset(2, 2),
                    blurRadius: 2,
                    color: Colors.black.withAlpha(51),
                  ),
                ],
              ),
            ),
          ),

          // 우하단 서브 텍스트
          Positioned(
            bottom: 5,
            right: 5,
            child: Text(
              data['sub'],
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 15,
                color: subTextColor,
                shadows: [
                  Shadow(
                    offset: const Offset(1.5, 1.5),
                    blurRadius: 3,
                    color: Colors.black.withAlpha(55),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
