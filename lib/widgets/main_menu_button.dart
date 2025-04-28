import 'package:flutter/material.dart';

class MainMenuButton extends StatelessWidget {
  final Map<String, dynamic> data;

  const MainMenuButton({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final Color textColor = data['textColor'] ?? Colors.white;

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
          Positioned(
            top: 0,
            left: 0,
            child: Icon(
              data['icon'],
              color: textColor,
              size: 24,
            ),
          ),
          Center(
            child: Text(
              data['label'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Text(
              data['sub'],
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 10,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
