class LoginRequestDto {
  const LoginRequestDto({
    required this.usernameOrEmail,
    required this.password,
  });

  final String usernameOrEmail;
  final String password;

  Map<String, dynamic> toJson() {
    return {
      'usernameOrEmail': usernameOrEmail.trim(),
      'password': password,
    };
  }
}

class RegisterRequestDto {
  RegisterRequestDto({
    required this.username,
    required this.email,
    required this.password,
    required this.fullName,
    this.phoneNumber,
  });

  final String username;
  final String email;
  final String password;
  final String fullName;
  final String? phoneNumber;

  Map<String, dynamic> toJson() {
    return {
      'username': username.trim(),
      'email': email.trim(),
      'password': password,
      'fullName': fullName.trim(),
      'phoneNumber': phoneNumber?.trim(),
    }..removeWhere((_, value) => value == null);
  }
}

class ForgotPasswordRequestDto {
  const ForgotPasswordRequestDto({
    required this.username,
    required this.email,
  });

  final String username;
  final String email;

  Map<String, dynamic> toJson() {
    return {
      'username': username.trim(),
      'email': email.trim(),
    };
  }
}
