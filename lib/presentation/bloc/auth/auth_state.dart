import 'package:equatable/equatable.dart';

import '../../../data/models/entity/user_entity.dart';
import '../common/bloc_status.dart';

class AuthState extends Equatable {
  const AuthState({
    this.status = BlocStatus.initial,
    this.user,
    this.errorMessage,
    this.isInitialized = false,
    this.requires2FA = false,
    this.sessionToken,
  });

  final BlocStatus status;
  final UserEntity? user;
  final String? errorMessage;
  final bool isInitialized;
  final bool requires2FA;
  final String? sessionToken;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    BlocStatus? status,
    UserEntity? user,
    bool userIsSet = false,
    String? errorMessage,
    bool clearError = false,
    bool? isInitialized,
    bool? requires2FA,
    String? sessionToken,
    bool clearSessionToken = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: userIsSet ? user : this.user,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isInitialized: isInitialized ?? this.isInitialized,
      requires2FA: requires2FA ?? this.requires2FA,
      sessionToken: clearSessionToken
          ? null
          : sessionToken ?? this.sessionToken,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    errorMessage,
    isInitialized,
    requires2FA,
    sessionToken,
  ];
}
