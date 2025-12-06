class User {
  final int id;
  final String loginId;
  final String email;
  final String nickname;
  final String? region;
  final String? interests;

  User({
    required this.id,
    required this.loginId,
    required this.email,
    required this.nickname,
    this.region,
    this.interests,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      loginId: json['loginId'],
      email: json['email'],
      nickname: json['nickname'],
      region: json['region'],
      interests: json['interests'],
    );
  }
}
