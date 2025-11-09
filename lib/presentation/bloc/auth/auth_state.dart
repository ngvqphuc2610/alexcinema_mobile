import 'package:equatable/equatable.dart';

import '../../../data/models/entity/user_entity.dart';
import '../common/bloc_status.dart';

class AuthState extends Equatable {
  const AuthState({
    this.status = BlocStatus.initial,
    this.user,
    this.errorMessage,
    this.isInitialized = false,
  });

  final BlocStatus status;
  final UserEntity? user;
  final String? errorMessage;
  final bool isInitialized;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    BlocStatus? status,
    UserEntity? user,
    bool userIsSet = false,
    String? errorMessage,
    bool clearError = false,
    bool? isInitialized,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: userIsSet ? user : this.user,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, isInitialized];
}
