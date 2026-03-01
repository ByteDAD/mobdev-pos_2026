class UserProfile {
  const UserProfile({
    required this.fullName,
    required this.username,
    required this.email,
    required this.nickname,
    required this.hobby,
    required this.social,
    required this.photoUrl,
  });

  final String fullName;
  final String username;
  final String email;
  final String nickname;
  final String hobby;
  final String social;
  final String photoUrl;

  UserProfile copyWith({
    String? fullName,
    String? username,
    String? email,
    String? nickname,
    String? hobby,
    String? social,
    String? photoUrl,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      hobby: hobby ?? this.hobby,
      social: social ?? this.social,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
