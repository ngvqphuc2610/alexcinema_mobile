import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../../data/models/dto/auth_response_dto.dart';
import '../../../data/services/api_client.dart';
import '../../../data/services/api_exception.dart';
import '../../../domain/services/auth_service.dart';
import '../common/bloc_status.dart';
import '../common/error_helpers.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authService) : super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthProfileRequested>(_onProfileRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<Auth2FARequested>(_on2FARequested);
  }

  final AuthService _authService;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    try {
      await _authService.initializeSession();
      await _loadProfile(emit, markInitialized: true);
    } catch (error) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          errorMessage: mapErrorMessage(error),
          isInitialized: true,
        ),
      );
    }
  }

  Future<void> _onProfileRequested(
    AuthProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    await _loadProfile(emit);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authAction(emit, () => _authService.login(event.request));
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authAction(emit, () => _authService.register(event.request));
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    try {
      await _authService.logout();
      emit(
        state.copyWith(
          status: BlocStatus.success,
          userIsSet: true,
          user: null,
          isInitialized: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          errorMessage: mapErrorMessage(error),
        ),
      );
    }
  }

  Future<void> _authAction(
    Emitter<AuthState> emit,
    Future<AuthResponseDto> Function() action,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    try {
      final response = await action();

      // Check if 2FA is required
      if (response.requires2FA == true && response.sessionToken != null) {
        emit(
          state.copyWith(
            status: BlocStatus.success,
            requires2FA: true,
            sessionToken: response.sessionToken,
            user: response.user,
            userIsSet: true,
            isInitialized: true,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: BlocStatus.success,
          user: response.user,
          userIsSet: true,
          isInitialized: true,
          requires2FA: false,
          clearSessionToken: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          errorMessage: mapErrorMessage(error),
        ),
      );
    }
  }

  Future<void> _on2FARequested(
    Auth2FARequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    try {
      final apiClient = sl<ApiClient>();
      final response = await apiClient.post(
        '/auth/verify-2fa',
        body: {
          'usernameOrEmail': event.usernameOrEmail,
          'token': event.token,
          'sessionToken': event.sessionToken,
        },
      );

      final authResponse = AuthResponseDto.fromJson(response);

      // Save token after successful 2FA
      if (authResponse.accessToken.isNotEmpty) {
        await _authService.persistToken(authResponse.accessToken);
      }

      emit(
        state.copyWith(
          status: BlocStatus.success,
          user: authResponse.user,
          userIsSet: true,
          isInitialized: true,
          requires2FA: false,
          clearSessionToken: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          errorMessage: mapErrorMessage(error),
        ),
      );
    }
  }

  Future<void> _loadProfile(
    Emitter<AuthState> emit, {
    bool markInitialized = false,
  }) async {
    try {
      final user = await _authService.getProfile();
      emit(
        state.copyWith(
          status: BlocStatus.success,
          userIsSet: true,
          user: user,
          isInitialized: markInitialized ? true : state.isInitialized,
        ),
      );
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        emit(
          state.copyWith(
            status: BlocStatus.success,
            userIsSet: true,
            user: null,
            isInitialized: markInitialized ? true : state.isInitialized,
            clearError: true,
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          errorMessage: error.message,
          isInitialized: markInitialized ? true : state.isInitialized,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          errorMessage: mapErrorMessage(error),
          isInitialized: markInitialized ? true : state.isInitialized,
        ),
      );
    }
  }
}
