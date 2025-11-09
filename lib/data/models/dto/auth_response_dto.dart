import '../entity/user_entity.dart';

class AuthResponseDto {
  const AuthResponseDto({
    required this.accessToken,
    required this.expiresIn,
    required this.user,
  });

  final String accessToken;
  final String expiresIn;
  final UserEntity user;

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      accessToken: json['accessToken'] as String? ?? '',
      expiresIn: json['expiresIn'] as String? ?? '',
      user: UserEntity.fromJson(
        json['user'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'expiresIn': expiresIn,
      'user': user.toJson(),
    };
  }
}
