import 'package:equatable/equatable.dart';

import '../../../data/models/dto/auth_request_dto.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthProfileRequested extends AuthEvent {
  const AuthProfileRequested();
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested(this.request);

  final LoginRequestDto request;

  @override
  List<Object?> get props => [request];
}

class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested(this.request);

  final RegisterRequestDto request;

  @override
  List<Object?> get props => [request];
}

class Auth2FARequested extends AuthEvent {
  const Auth2FARequested({
    required this.sessionToken,
    required this.token,
    required this.usernameOrEmail,
  });

  final String sessionToken;
  final String token;
  final String usernameOrEmail;

  @override
  List<Object?> get props => [sessionToken, token, usernameOrEmail];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
