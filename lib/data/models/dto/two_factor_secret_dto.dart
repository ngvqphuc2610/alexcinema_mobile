class TwoFactorSecretDto {
  const TwoFactorSecretDto({
    required this.secret,
    required this.qrCodeUrl,
  });

  final String secret;
  final String qrCodeUrl;

  factory TwoFactorSecretDto.fromJson(Map<String, dynamic> json) {
    return TwoFactorSecretDto(
      secret: json['secret'] as String,
      qrCodeUrl: json['qrCodeUrl'] as String,
    );
  }
}
