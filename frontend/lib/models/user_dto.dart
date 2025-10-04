class UserDto {
  final String kakaoId;
  final String nickname;
  final String profileImageUrl;

  UserDto({
    required this.kakaoId,
    required this.nickname,
    required this.profileImageUrl,
  });

  Map<String, dynamic> toJson() => {
    'kakao_id': kakaoId,
    'nickname': nickname,
    'profile_image_url': profileImageUrl,
  };
}
