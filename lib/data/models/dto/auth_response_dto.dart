import '../entity/user_entity.dart';

class AuthResponseDto {
  const AuthResponseDto({
    required this.accessToken,
    required this.expiresIn,
    required this.user,
    this.requires2FA,
    this.sessionToken,
  });

  final String accessToken;
  final String expiresIn;
  final UserEntity user;
  final bool? requires2FA;
  final String? sessionToken;

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      accessToken: json['accessToken'] as String? ?? '',
      expiresIn: json['expiresIn'] as String? ?? '',
      user: UserEntity.fromJson(
        json['user'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      requires2FA: json['requires2FA'] as bool?,
      sessionToken: json['sessionToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'expiresIn': expiresIn,
      'user': user.toJson(),
      if (requires2FA != null) 'requires2FA': requires2FA,
      if (sessionToken != null) 'sessionToken': sessionToken,
    };
  }
}
