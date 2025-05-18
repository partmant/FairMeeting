import 'package:flutter/material.dart';

class UserInfoBox extends StatelessWidget {
  final String userName;
  final String profileImageUrl;

  const UserInfoBox({
    super.key,
    required this.userName,
    required this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: profileImageUrl.isNotEmpty
                ? NetworkImage(profileImageUrl)
                : null,
            child: profileImageUrl.isEmpty
                ? const Icon(Icons.account_circle, size: 48, color: Colors.grey)
                : null,
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(width: 16),
          Text(
            userName.isNotEmpty ? userName : '로그인 필요',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
